# byya Root Physical GNSS Control

This KernelSU WebUI module leaves Android's master location switch and all app
permissions untouched. It controls only physical GNSS-related init services:

- **Normal:** all detected services restored.
- **Weaken assistance:** GNSS aiding data is cleared and auxiliary services such
  as Qualcomm `loc_launcher`/XTRA are paused. Physical satellites can still fix
  a position, so this does not fully prevent location jumps.
- **Isolate physical GNSS:** the detected GNSS HAL init service is stopped while
  Android location remains enabled. Mock and network providers can continue to
  supply locations through the framework.

Service discovery is runtime-based for portability. Unsupported ROMs fail
safely instead of stopping unrelated services. Uninstall restores every service
that the module recorded as stopped.
