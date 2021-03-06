# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=FGO Patch
do.devicecheck=0
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=kenzo
device.name2=
device.name3=
device.name4=
device.name5=
} # end properties

# shell variables
#block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

#detect boot 
find_boot_image() {
  if [ -z "$block" ]; then
    for PARTITION in kern-a KERN-A android_boot ANDROID_BOOT kernel KERNEL boot BOOT lnx LNX; do
      block=`readlink /dev/block/by-name/$PARTITION || readlink /dev/block/platform/*/by-name/$PARTITION || readlink /dev/block/platform/*/*/by-name/$PARTITION`
      if [ ! -z "$block" ]; then break; fi
    done
  fi
  if [ -z "$block" ]; then
    FSTAB="/etc/recovery.fstab"
    [ ! -f "$FSTAB" ] && FSTAB="/etc/recovery.fstab.bak"
    [ -f "$FSTAB" ] && block=`grep -E '\b/boot\b' "$FSTAB" | grep -oE '/dev/[a-zA-Z0-9_./-]*'`
  fi
  if [ -z "$block" ]; then
    ui_print " "; 
	ui_print "Unable to determine active boot slot. Aborting..."; 
	exit 1;
  fi;
}


## AnyKernel permissions
# set permissions for included ramdisk files
#chmod -R 755 $ramdisk
#chmod 644 $ramdisk/sbin/media_profiles.xml


## AnyKernel install
find_boot_image;

ui_print "[#] Updating default.prop..."

dump_boot;

# begin ramdisk changes

# update default.prop
patch_prop "default.prop" "ro.debuggable" "0"
patch_prop "default.prop" "persist.sys.usb.config" "mtp"

# end ramdisk changes

write_boot;

ui_print "[#] Done"

# start system changes
ui_print "[#] Updating build.prop..."

patch_prop "/system/build.prop" "ro.build.type" "user"

ui_print "[#] Done"

## end install

