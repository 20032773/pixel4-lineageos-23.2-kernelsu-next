#!/usr/bin/env python3
"""Reject a custom kernel when it changes the baseline module symbol ABI."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def read_symvers(path: Path) -> dict[str, str]:
    symbols: dict[str, str] = {}
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        fields = line.split()
        if not fields:
            continue
        if len(fields) < 2:
            raise ValueError(f"{path}:{line_number}: malformed Module.symvers line")
        crc, symbol = fields[0].lower(), fields[1]
        if symbol in symbols and symbols[symbol] != crc:
            raise ValueError(f"{path}:{line_number}: duplicate CRC for {symbol}")
        symbols[symbol] = crc
    if not symbols:
        raise ValueError(f"{path}: no exported symbols found")
    return symbols


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("baseline", type=Path)
    parser.add_argument("custom", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    try:
        baseline = read_symvers(args.baseline)
        custom = read_symvers(args.custom)
    except (OSError, ValueError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    missing = sorted(set(baseline) - set(custom))
    changed = sorted(
        (symbol, baseline[symbol], custom[symbol])
        for symbol in baseline.keys() & custom.keys()
        if baseline[symbol] != custom[symbol]
    )
    added = sorted(set(custom) - set(baseline))

    lines = [
        f"baseline_symbols={len(baseline)}",
        f"custom_symbols={len(custom)}",
        f"added_symbols={len(added)}",
        f"missing_symbols={len(missing)}",
        f"changed_crcs={len(changed)}",
    ]
    lines.extend(f"missing {symbol}" for symbol in missing)
    lines.extend(
        f"changed {symbol} baseline={old_crc} custom={new_crc}"
        for symbol, old_crc, new_crc in changed
    )
    report = "\n".join(lines) + "\n"
    print(report, end="")
    if args.report:
        args.report.write_text(report, encoding="utf-8")

    if missing or changed:
        print(
            "error: custom kernel is incompatible with the LineageOS vendor modules",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
