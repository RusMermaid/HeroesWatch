"""Check internal navigation in a published Heroes Watch site."""

import re
import subprocess
import sys
import tempfile
import time
from collections import defaultdict
from contextlib import closing
from html.parser import HTMLParser
from http.client import HTTPConnection
from pathlib import Path
from urllib.parse import urlsplit


GAME_NAMES = (
    "Heroes I", "Heroes II", "Heroes III", "Heroes IV",
    "Heroes V", "Heroes VI", "Heroes VII", "Olden Era",
)
MENU = [("All", "/")] + [
    (name, f"/heroes/{number}") for number, name in enumerate(GAME_NAMES, start=1)
]
SECTIONS = {"News": "/", "Lore": "/lore", "About": "/about"}
BOARDS = {
    "General discussion": "/boards/general",
    "Strategy & tactics": "/boards/strategy",
    "Fan projects": "/boards/fan-projects",
}


def expect(actual, expected, location):
    if actual != expected:
        raise AssertionError(f"{location}: expected {expected!r}, got {actual!r}")


class NavigationPage(HTMLParser):
    void = set("area base br col embed hr img input link meta param source track wbr".split())

    def __init__(self):
        super().__init__()
        self.stack = [("", "", False)]
        self.captures = []
        self.links = defaultdict(list)
        self.headings = defaultdict(list)
        self.game_summaries = []
        self.wordmark = None

    def handle_starttag(self, tag, attrs):
        if tag in self.void:
            return
        attrs = dict(attrs)
        _, region, hidden = self.stack[-1]
        if tag == "aside":
            region = attrs.get("aria-labelledby") or attrs.get("aria-label") or tag
        elif tag == "details" and "heroes-menu" in attrs.get("class", "").split():
            region = "games"
        elif tag in ("main", "nav", "header"):
            region = tag
        hidden = hidden or "hidden" in attrs or attrs.get("aria-hidden") == "true"
        self.stack.append((tag, region, hidden))
        if not hidden and tag in ("a", "h1", "h2", "summary"):
            self.captures.append((tag, attrs, []))

    def handle_data(self, data):
        if not self.stack[-1][2]:
            for _, _, parts in self.captures:
                parts.append(data)

    def handle_endtag(self, tag):
        if tag != self.stack[-1][0]:
            return
        _, region, hidden = self.stack.pop()
        if hidden or not self.captures or self.captures[-1][0] != tag:
            return
        _, attrs, parts = self.captures.pop()
        label = " ".join("".join(parts).split())
        if tag == "a":
            href = attrs.get("href")
            self.links[region].append((label, href, attrs.get("aria-current") or "false"))
            if region == "header" and "wordmark" in attrs.get("class", "").split() and label:
                self.wordmark = href
        elif tag == "summary" and region == "games":
            self.game_summaries.append(label)
        elif region == "main":
            self.headings[tag].append(label)

    def href(self, region, name, expected):
        matches = [href for label, href, _ in self.links[region] if label == name]
        expect(matches, [expected], f"{region} link {name!r}")
        return matches[0]


def check_navigation(base_url):
    host = urlsplit(base_url).netloc

    def visit(path, heading, game=None, empty_board=False):
        with closing(HTTPConnection(host, timeout=10)) as client:
            client.request("GET", path)
            with client.getresponse() as response:
                expect(response.status, 200, path)
                page = NavigationPage()
                page.feed(response.read().decode("utf-8"))
                page.close()

        active = "All" if path == "/" else game
        expected_menu = [(name, href, "page" if name == active else "false") for name, href in MENU]
        expect(page.links["games"], expected_menu, f"{path} game menu")
        expect(page.game_summaries, ["Heroes"], f"{path} game menu control")
        expect(page.headings["h1"], [heading], f"{path} H1")
        expect(page.wordmark, "/", f"{path} home wordmark")
        if empty_board:
            expect("Under construction" in page.headings["h2"], True, f"{path} construction notice")
        return page

    home = visit("/", "News")
    for name, href in MENU[1:]:
        game = visit(home.href("games", name, href), f"{name} News", game=name)
        visit(game.href("games", "All", "/"), "News")

    for name, href in SECTIONS.items():
        section = visit(home.href("nav", name, href), name)
        visit(section.wordmark, "News")

    directory = visit(home.href("Community", "Browse boards", "/boards"), "Discussion boards", empty_board=True)
    for source, region in ((home, "board-rail-heading"), (directory, "main")):
        for title, href in BOARDS.items():
            board = visit(source.href(region, title, href), title, empty_board=True)
            visit(board.href("Community", "Browse boards", "/boards"), "Discussion boards", empty_board=True)
            visit(board.wordmark, "News")


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
    print("Verified the Heroes menu, main sections, board links, empty-board notices and home wordmark.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python game_navigation.py <published-directory>")
    main(Path(sys.argv[1]).resolve())
