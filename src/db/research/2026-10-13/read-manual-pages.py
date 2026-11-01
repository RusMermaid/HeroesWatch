"""Read selected PDF pages over HTTPS ranges without a full-manual download.

Research helper only. Output is a small local reference PDF, never game data.
The server must support byte ranges; transfer is capped at 16 MiB by default.
"""
import argparse
import io
import json
import urllib.request
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from pypdf.generic import ContentStream, DictionaryObject, NameObject


class RangeReader(io.RawIOBase):
    def __init__(self, url, byte_limit):
        if not url.startswith("https://"):
            raise ValueError("HTTPS required")
        self.url, self.byte_limit = url, byte_limit
        request = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(request, timeout=30) as response:
            self.length = int(response.headers["Content-Length"])
            self.etag = response.headers.get("ETag")
        self.position, self.transferred = 0, 0
        self.chunk_size = 65536
        self.cache = {}

    def seekable(self):
        return True

    def readable(self):
        return True

    def tell(self):
        return self.position

    def seek(self, offset, whence=io.SEEK_SET):
        position = offset if whence == io.SEEK_SET else (
            self.position + offset if whence == io.SEEK_CUR else self.length + offset)
        if position < 0:
            raise ValueError("Negative PDF seek")
        self.position = position
        return position

    def read(self, size=-1):
        end = self.length if size < 0 else min(self.position + size, self.length)
        pieces = []
        while self.position < end:
            index = self.position // self.chunk_size
            if index not in self.cache:
                first = index * self.chunk_size
                last = min(first + self.chunk_size, self.length) - 1
                length = last - first + 1
                if self.transferred + length > self.byte_limit:
                    raise RuntimeError("Reference transfer limit reached; no full download attempted")
                headers = {"Range": f"bytes={first}-{last}"}
                if self.etag:
                    headers["If-Match"] = self.etag
                request = urllib.request.Request(self.url, headers=headers)
                with urllib.request.urlopen(request, timeout=30) as response:
                    if response.status != 206:
                        raise RuntimeError("Server did not honor the byte range; refusing full PDF")
                    if response.headers.get("Content-Range") != f"bytes {first}-{last}/{self.length}":
                        raise RuntimeError("Unexpected PDF byte range")
                    chunk = response.read(length + 1)
                if len(chunk) != length:
                    raise RuntimeError("Incomplete PDF byte range")
                self.transferred += length
                self.cache[index] = chunk
            offset = self.position % self.chunk_size
            take = min(end - self.position, len(self.cache[index]) - offset)
            pieces.append(self.cache[index][offset:offset + take])
            self.position += take
        return b"".join(pieces)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("url")
    parser.add_argument("--pages", required=True, help="1-based PDF page numbers/ranges, e.g. 160-168,193")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--max-mib", type=int, default=16)
    args = parser.parse_args()
    if args.output.exists():
        raise ValueError("Choose a new output path; reference files are never overwritten")
    pages = []
    for group in args.pages.split(","):
        bounds = list(map(int, group.split("-")))
        pages.extend(range(bounds[0], bounds[-1] + 1))
    remote = RangeReader(args.url, args.max_mib * 1024 * 1024)
    # Strict mode trusts the valid xref rather than scanning every object in a
    # linearized 58 MB PDF for repair. A broken xref is a hard stop, not a reason
    # to download the entire manual behind the transfer cap.
    reader = PdfReader(remote, strict=True)
    writer = PdfWriter()
    observations = []
    for number in pages:
        if not 1 <= number <= len(reader.pages):
            raise ValueError(f"Invalid page {number}")
        page = reader.pages[number - 1]
        # This manual shares a very large resource dictionary between pages.
        # Retain only resources actually invoked by this page's content stream.
        # Form XObjects keep their own resources; the visual subset is checked
        # after rendering rather than assumed equivalent from extraction alone.
        needed = {"/Font": set(), "/XObject": set(), "/ExtGState": set(),
                  "/ColorSpace": set(), "/Pattern": set(), "/Properties": set()}
        for operands, operator in ContentStream(page.get_contents(), reader).operations:
            if operator == b"Tf": needed["/Font"].add(operands[0])
            elif operator == b"Do": needed["/XObject"].add(operands[0])
            elif operator == b"gs": needed["/ExtGState"].add(operands[0])
            elif operator in (b"CS", b"cs"): needed["/ColorSpace"].add(operands[0])
            elif operator in (b"SCN", b"scn") and operands and isinstance(operands[-1], NameObject):
                needed["/Pattern"].add(operands[-1])
            elif operator in (b"BDC", b"DP") and operands and isinstance(operands[-1], NameObject):
                needed["/Properties"].add(operands[-1])
        original_resources = page["/Resources"].get_object()
        resources = DictionaryObject()
        for category, names in needed.items():
            if category in original_resources and names:
                values = original_resources[category].get_object()
                resources[NameObject(category)] = DictionaryObject({
                    name: values.raw_get(name) for name in names if name in values})
        if "/ProcSet" in original_resources:
            resources[NameObject("/ProcSet")] = original_resources.raw_get("/ProcSet")
        page[NameObject("/Resources")] = resources
        text = page.extract_text()
        # Short headings only, not a bulk copy of source prose into logs.
        observations.append({"pdfPage": number, "heading": text[:140], "footer": text[-80:]})
        # Page links can point into the entire book; only page graphics/text are
        # needed for this local visual reference, not annotations or article trees.
        writer.add_page(page, excluded_keys=("/Annots", "/B"))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("xb") as stream:
        writer.write(stream)
    print(json.dumps({"source": args.url, "etag": remote.etag, "sourceBytes": remote.length,
                      "transferredBytes": remote.transferred, "outputBytes": args.output.stat().st_size,
                      "pageCount": len(reader.pages), "observations": observations}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
