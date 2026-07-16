# byya Pixel 4 Balanced Cool Profile

KernelSU module for Pixel 4 (`flame`) using the following maximum frequencies:

- CPU efficiency cluster: 1.632 GHz (stock 1.7856 GHz)
- CPU performance cluster: 1.920 GHz (stock 2.4192 GHz)
- CPU prime core: 2.1312 GHz (stock 2.8416 GHz)
- GPU: 499.2 MHz (stock 585 MHz)

The module does not modify or disable Android/Qualcomm thermal controls. Every
write is lowering-only: if thermal control has already selected a lower maximum,
the script leaves it untouched. Disable or remove the module and reboot to
restore stock limits.
