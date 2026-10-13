#!/usr/bin/env python3
"""Read selected records from a Heroes III LOD archive without modifying it.

The extractor is intentionally narrow: callers must name each member to copy,
and path components are stripped from member names.  It supports stored and
zlib-compressed records used by the classic Heroes III data archives.
"""

from __future__ import annotations

import argparse
import struct
import zlib
from pathlib import Path


HEADER_SIZE = 92
ENTRY_SIZE = 32


def read_directory(archive: Path) -> dict[str, tuple[int, int, int]]:
    with archive.open("rb") as handle:
        header = handle.read(HEADER_SIZE)
        if len(header) != HEADER_SIZE or header[:4] != b"LOD\x00":
            raise ValueError(f"{archive} is not a Heroes III LOD archive")
        count = struct.unpack_from("<I", header, 8)[0]
        entries: dict[str, tuple[int, int, int]] = {}
        for _ in range(count):
            raw = handle.read(ENTRY_SIZE)
            if len(raw) != ENTRY_SIZE:
                raise ValueError(f"truncated LOD directory in {archive}")
            name_bytes, offset, size, _kind, compressed_size = struct.unpack(
                "<16sIIII", raw
            )
            name = name_bytes.split(b"\x00", 1)[0].decode("ascii")
            entries[name.upper()] = (offset, size, compressed_size)
        return entries


def extract_member(archive: Path, entry: tuple[int, int, int]) -> bytes:
    offset, size, compressed_size = entry
    stored_size = compressed_size or size
    with archive.open("rb") as handle:
        handle.seek(offset)
        payload = handle.read(stored_size)
    if len(payload) != stored_size:
        raise ValueError(f"truncated LOD record at offset {offset} in {archive}")
    result = zlib.decompress(payload) if compressed_size else payload
    if len(result) != size:
        raise ValueError(
            f"LOD record at offset {offset} expanded to {len(result)}, expected {size}"
        )
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("members", nargs="+")
    args = parser.parse_args()

    directory = read_directory(args.archive)
    args.output.mkdir(parents=True, exist_ok=True)
    for requested in args.members:
        key = requested.upper()
        if key not in directory:
            raise SystemExit(f"{requested}: not found in {args.archive}")
        destination = args.output / Path(requested).name
        destination.write_bytes(extract_member(args.archive, directory[key]))
        print(f"{key}\t{destination}\t{destination.stat().st_size}")


if __name__ == "__main__":
    main()
