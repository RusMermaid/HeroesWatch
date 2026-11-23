"""Check the game labels and links rendered by a published Heroes Watch site."""

import re
import subprocess
import sys
import tempfile
import time
from html.parser import HTMLParser
from pathlib import Path
from urllib.request import ProxyHandler, build_opener


GAME_NAMES = (
    "Heroes I", "Heroes II", "Heroes III", "Heroes IV",
    "Heroes V", "Heroes VI", "Heroes VII", "Olden Era",
)
MENU = [("All", "/")] + [
    (name, f"/heroes/{number}") for number, name in enumerate(GAME_NAMES, start=1)
]


class GamePage(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_menu = False
        self.capture = None
        self.links = []
        self.headings = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "details" and "heroes-menu" in attrs.get("class", "").split():
            self.in_menu = True
        elif tag == "h1" or (tag == "a" and self.in_menu):
            self.capture = tag
            self.attrs = attrs
            self.parts = []

    def handle_data(self, data):
        if self.capture:
            self.parts.append(data)

    def handle_endtag(self, tag):
        if tag == "details":
            self.in_menu = False
        elif tag == self.capture:
            label = " ".join("".join(self.parts).split())
            if tag == "h1":
                self.headings.append(label)
            else:
                current = self.attrs.get("aria-current") or "false"
                self.links.append((label, self.attrs.get("href"), current))
            self.capture = None


def check_navigation(base_url):
    client = build_opener(ProxyHandler({}))

    def visit(path, active, heading):
        with client.open(base_url + path, timeout=10) as response:
            page = GamePage()
            page.feed(response.read().decode("utf-8"))
            page.close()

        expected = [(name, href, "page" if name == active else "false") for name, href in MENU]
        if page.links != expected:
            raise AssertionError(f"{path} expected menu {expected!r}, got {page.links!r}")
        if page.headings != [heading]:
            raise AssertionError(f"{path} expected H1 {heading!r}, got {page.headings!r}")
        return {name: href for name, href, _ in page.links}

    home_links = visit("/", "All", "News")
    for name in GAME_NAMES:
        game_links = visit(home_links[name], name, f"{name} News")
        visit(game_links["All"], "All", "News")


def listening_url(server, log):
    deadline = time.monotonic() + 30
    while server.poll() is None and time.monotonic() < deadline:
        output = log.read_text(encoding="utf-8", errors="replace")
        match = re.search(r"Now listening on:\s+(http://127\.0\.0\.1:\d+)", output)
        if match:
            return match.group(1)
        time.sleep(0.1)
    raise RuntimeError(f"Kestrel failed to start:\n{log.read_text(encoding='utf-8', errors='replace')}")


def main(published):
    with tempfile.TemporaryDirectory() as temp:
        log = Path(temp) / "kestrel.log"
        with log.open("wb") as output:
            server = subprocess.Popen(
                ["dotnet", "HeroesWatch.Web.dll", "--urls", "http://127.0.0.1:0",
                 "--Logging:LogLevel:Microsoft.Hosting.Lifetime=Information"],
                cwd=published, stdout=output, stderr=subprocess.STDOUT,
            )
            try:
                check_navigation(listening_url(server, log))
            finally:
                server.terminate()
                try:
                    server.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    server.kill()
                    server.wait()
    print("Verified the eight Heroes game links, headings, active states and return to All.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python game_navigation.py <published-directory>")
    main(Path(sys.argv[1]).resolve())
