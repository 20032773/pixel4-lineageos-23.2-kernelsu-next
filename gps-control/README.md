# byya Root GPS Control

Portable KernelSU WebUI module for hot-switching Android location behavior.

- Normal: restore location, GNSS services, and target-app AppOps.
- Flight stable: stop detected real GNSS init services while leaving Android
  location enabled for mock/network providers.
- Approximate: deny fine location to the selected package, allow coarse.
- App blocked: deny both fine and coarse location to the selected package.
- All off: disable Android's master location switch.

Default target: `com.nianticlabs.pokemongo`.

GNSS service discovery is runtime-based rather than device-name-based, but ROMs
that hide or rename their GNSS service may not support Flight stable mode. The
controller fails without changing its saved mode when no GNSS service is found.
Normal mode and module uninstall both attempt to restore stopped services.
