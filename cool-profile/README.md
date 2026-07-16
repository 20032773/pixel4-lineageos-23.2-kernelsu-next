# byya Pixel 4 Balanced Cool Profile

KernelSU module for Pixel 4 (`flame`) using the following maximum frequencies:

- CPU efficiency cluster: 1.632 GHz (stock 1.7856 GHz)
- CPU performance cluster: 1.7088 GHz (stock 2.4192 GHz)
- CPU prime core: 1.920 GHz (stock 2.8416 GHz)
- GPU: 427 MHz (stock 585 MHz)
- Pokémon GO: unrestricted FPS (`fps-override: 0`) and 0.85 render scale through
  Android Game Manager
- Display refresh rate is not modified

The module does not modify or disable Android/Qualcomm thermal controls. Every
write is lowering-only: if thermal control has already selected a lower maximum,
the script leaves it untouched. Disable or remove the module and reboot to
restore stock limits. The service checks the caps every 15 seconds because the
Pixel Power HAL may rewrite frequency limits after boot or during app boosts.
