#!/usr/bin/env python3
"""Hide private KernelSU switches from genksyms without disabling KernelSU."""

from pathlib import Path
import sys


MARKER = "Pixel 4 vendor-module kABI preservation"
ANCHOR = "#include <generated/autoconf.h>"
BLOCK = f"""{ANCHOR}

/* {MARKER}
 *
 * KernelSU's manual hooks in this builder change function bodies only.  They
 * do not change exported prototypes or public structure layouts.  Keep those
 * private feature switches out of genksyms' preprocessed input so the kernel
 * continues to publish the CRCs used by LineageOS's prebuilt flame modules.
 * Normal C compilation does not define __GENKSYMS__, so KernelSU remains on.
 */
#ifdef __GENKSYMS__
#undef CONFIG_KSU
#undef CONFIG_KSU_MANUAL_HOOK
#undef CONFIG_KSU_DEBUG
#undef CONFIG_KSU_KPROBES_HOOK
#undef CONFIG_KSU_HOOK_KPROBES
#undef CONFIG_KSU_WITH_KPROBES
#endif
"""


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} <include/linux/kconfig.h>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    source = path.read_text(encoding="utf-8")
    if MARKER in source:
        print("[*] genksyms KernelSU isolation is already installed")
        return 0
    if source.count(ANCHOR) != 1:
        print(
            f"error: expected exactly one {ANCHOR!r}, found {source.count(ANCHOR)}",
            file=sys.stderr,
        )
        return 1

    path.write_text(source.replace(ANCHOR, BLOCK, 1), encoding="utf-8")
    print("[+] Isolated private KernelSU switches from genksyms")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
