#!/usr/bin/env python3
"""Apply strict KernelSU Next legacy compatibility fixes for Linux 4.14."""

from pathlib import Path
import sys


ROOT = Path("kernel-source")
if not ROOT.exists():
    ROOT = Path(".")

EVENT = ROOT / "drivers" / "kernelsu" / "sulog" / "event.c"
EVENT_QUEUE = ROOT / "drivers" / "kernelsu" / "infra" / "event_queue.h"
DISPATCH = ROOT / "drivers" / "kernelsu" / "supercall" / "dispatch.c"
LINUX_TYPES = ROOT / "include" / "uapi" / "linux" / "types.h"
SECCOMP = ROOT / "include" / "linux" / "seccomp.h"

TIMESPEC_MARKER = "Linux 4.14 boottime type compatibility"
POLL_MARKER = "vendor kernel already defines __poll_t"
SCHED_MARKER = "Linux 4.14 scheduler declarations"
SECCOMP_MARKER = "Pixel 4 kABI-compatible KernelSU filter counter"


def patch_timespec() -> None:
    source = EVENT.read_text(encoding="utf-8")
    if source.count(TIMESPEC_MARKER) == 2:
        print("[*] KernelSU Next SULog boottime types are already patched")
        return

    old = "    struct timespec64 ts;"
    if source.count(old) != 2:
        raise RuntimeError(
            "SULog timespec declarations: expected exactly two upstream matches, "
            f"found {source.count(old)}"
        )

    new = """    /* Linux 4.14 boottime type compatibility */
#if KERNEL_VERSION(4, 19, 0) <= LINUX_VERSION_CODE
    struct timespec64 ts;
#else
    struct timespec ts;
#endif"""
    EVENT.write_text(source.replace(old, new), encoding="utf-8")
    print("[+] Patched KernelSU Next SULog boottime types for Linux 4.14")


def patch_poll_type() -> None:
    queue = EVENT_QUEUE.read_text(encoding="utf-8")
    types = LINUX_TYPES.read_text(encoding="utf-8")
    if POLL_MARKER in queue:
        print("[*] KernelSU Next __poll_t compatibility is already patched")
        return

    if "typedef unsigned __poll_t;" not in types:
        print("[*] Target kernel does not backport __poll_t; keeping fallback")
        return

    old = """#include <linux/version.h>
#if LINUX_VERSION_CODE < KERNEL_VERSION(4, 16, 0)
typedef unsigned int __poll_t;
#endif"""
    if queue.count(old) != 1:
        raise RuntimeError(
            "event_queue __poll_t fallback: expected exactly one upstream match, "
            f"found {queue.count(old)}"
        )

    new = """#include <linux/version.h>
/* Pixel vendor kernel already defines __poll_t in linux/types.h. */"""
    EVENT_QUEUE.write_text(queue.replace(old, new, 1), encoding="utf-8")
    print("[+] Removed duplicate KernelSU Next __poll_t typedef")


def patch_scheduler_includes() -> None:
    source = DISPATCH.read_text(encoding="utf-8")
    if SCHED_MARKER in source:
        print("[*] KernelSU Next scheduler declarations are already included")
        return

    old = "#include <linux/thread_info.h>"
    if source.count(old) != 1:
        raise RuntimeError(
            "dispatch scheduler include point: expected exactly one upstream match, "
            f"found {source.count(old)}"
        )

    new = """#include <linux/thread_info.h>
/* Linux 4.14 scheduler declarations */
#include <linux/sched/signal.h>
#include <linux/sched/task.h>"""
    DISPATCH.write_text(source.replace(old, new, 1), encoding="utf-8")
    print("[+] Added Linux 4.14 scheduler declarations to KernelSU dispatch")


def patch_seccomp_filter_counter() -> None:
    """Use seccomp's arm64 alignment hole without changing its module CRC."""
    source = SECCOMP.read_text(encoding="utf-8")
    if SECCOMP_MARKER in source:
        print("[*] KernelSU seccomp filter counter is already kABI-safe")
        return

    include_anchor = "#include <linux/thread_info.h>"
    field_anchor = "\tint mode;"
    if source.count(include_anchor) != 1 or source.count(field_anchor) != 1:
        raise RuntimeError(
            "seccomp filter counter: expected one thread_info include and one "
            f"mode field, found {source.count(include_anchor)} and "
            f"{source.count(field_anchor)}"
        )

    source = source.replace(
        include_anchor,
        include_anchor + "\n#include <linux/atomic.h>",
        1,
    )
    guarded_counter = f"""\tint mode;
#ifndef __GENKSYMS__
\t/* {SECCOMP_MARKER}: fills the existing 4-byte arm64 alignment hole. */
\tatomic_t filter_count;
#endif"""
    SECCOMP.write_text(
        source.replace(field_anchor, guarded_counter, 1), encoding="utf-8"
    )
    print("[+] Added the KernelSU seccomp counter without changing module kABI")


def main() -> int:
    missing = [
        path
        for path in (EVENT, EVENT_QUEUE, DISPATCH, LINUX_TYPES, SECCOMP)
        if not path.is_file()
    ]
    if missing:
        print("error: missing required files: " + ", ".join(map(str, missing)), file=sys.stderr)
        return 1

    try:
        patch_timespec()
        patch_poll_type()
        patch_scheduler_includes()
        patch_seccomp_filter_counter()
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
