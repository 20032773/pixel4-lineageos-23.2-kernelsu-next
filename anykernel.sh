# AnyKernel3 Tool Template
# Home: https://github.com/osm0sis/AnyKernel3

properties() { '
kernel.string=KernelSU Next for Pixel 4 (flame)
do.devicecheck=1
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
device.name1=flame
supported.versions=16
supported.patchlevels=
'; }

# Pixel 4 is an A/B device. Auto-detection keeps the current boot slot and
# preserves the LineageOS ramdisk and the boot header v2 DTB while replacing
# only Image.lz4.
BLOCK=auto;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

. tools/ak3-core.sh;

dump_boot;
write_boot;

exit 0;
