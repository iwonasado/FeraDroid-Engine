#!/system/bin/sh
### FeraDroid Engine v0.20 | By FeraVolt. 2016 ###
B=/system/engine/bin/busybox
LOG=/sdcard/Android/FDE.txt
ARCH=$($B uname -m)
TIME=$($B date | $B awk '{ print $4 }')
SDK=$(getprop ro.build.version.sdk)
$B echo "[$TIME] 006 - ***GPU gear***" >> $LOG
$B echo "Remounting /system - RW" >> $LOG
$B mount -o remount,rw /system
$B mount -t debugfs debugfs /sys/kernel/debug
if [ -e /system/lib/egl/libGLESv2_adreno200.so ]; then
 $B echo "Adreno GPU detected" >> $LOG
 if [ "$SDK" -eq "10" ]; then
  if [ -e /init.es209ra.rc ]; then
   if [ -e /system/etc/adreno_config.txt ]; then
    $B rm -f /system/etc/adreno_config.txt
    $B rm -f /data/local/tmp/adreno_config.txt
   fi;
   $B echo "X10 adreno 'config'.." >> $LOG
  elif [ ! -h /data/local/tmp/adreno_config.txt ]; then
   $B echo "Applying Adreno configurations.." >> $LOG
   $B chmod 755 /system/engine/assets/adreno_config.txt
   $B ln -s /system/engine/assets/adreno_config.txt /data/local/tmp/adreno_config.txt
  fi;
 fi;
 $B echo "Setting correct device permissions.." >> $LOG
 $B chmod 666 /dev/kgsl-3d0
 $B chmod 666 /dev/msm_aac_in
 $B chmod 666 /dev/msm_amr_in
 $B chmod 666 /dev/genlock
 $B echo "Tuning Android and Adreno frienship.." >> $LOG
 setprop com.qc.hardware true
 setprop debug.qc.hardware true
 setprop debug.qctwa.statusbar 1
 setprop debug.qctwa.perservebuf 1
fi;
if [ "$SDK" -eq "10" ]; then
 if [ -e /system/lib/egl/libGLES_android.so ]; then
  if [ -e /system/lib/egl/egl.cfg ]; then
   if [ -e /system/lib/egl/libGLESv2_adreno200.so ]; then
    AV=$(du -k "/system/lib/egl/libGLESv2_adreno200.so" | cut -f1)
    if [ "$AV" -eq "1712" ]; then
     $B echo "You have legacy adreno libs. No HWA for you." >> $LOG
     exit
    fi;
   fi;
   $B echo "Forcing GPU to render UI.." >> $LOG
   $B mount -o remount,rw /system
   $B sed -i '/0 0 android/d' /system/lib/egl/egl.cfg
   $B rm /system/lib/egl/libGLES_android.so
  fi;
 fi;
fi;
if [ -e /sys/module/mali/parameters/mali_debug_level ]; then
 $B echo "Mali GPU detected. Tuning.." >> $LOG
 $B chown 0:0 /sys/module/mali/parameters/mali_debug_level
 $B chmod 644 /sys/module/mali/parameters/mali_debug_level
 $B echo 0 > /sys/module/mali/parameters/mali_debug_level
 if [ -e /sys/module/mali/parameters/mali_gpu_utilization_timeout ]; then
  $B echo "Mali util-timiout tuned." >> $LOG
  $B chown 0:0 /sys/module/mali/parameters/mali_gpu_utilization_timeout
  $B chmod 644 /sys/module/mali/parameters/mali_gpu_utilization_timeout
  $B echo 100 > /sys/module/mali/parameters/mali_gpu_utilization_timeout
 fi;
 if [ -e /sys/module/mali/parameters/mali_touch_boost_level ]; then
  $B echo "Mali touch-boost tuned." >> $LOG
  $B chown 0:0 /sys/module/mali/parameters/mali_touch_boost_level
  $B chmod 644 /sys/module/mali/parameters/mali_touch_boost_level
  $B echo 1 > /sys/module/mali/parameters/mali_touch_boost_level
 fi;
 if [ -e /sys/module/mali/parameters/mali_l2_max_reads ]; then
  $B echo "Mali L2 cache tuned." >> $LOG
  $B chown 0:0 /sys/module/mali/parameters/mali_l2_max_reads
  $B chmod 644 /sys/module/mali/parameters/mali_l2_max_reads
  $B echo 48 > /sys/module/mali/parameters/mali_l2_max_reads
 fi;
 if [ -e /sys/module/mali/parameters/mali_pp_scheduler_balance_jobs ]; then
  $B echo "Mali PP tuned." >> $LOG
  $B chown 0:0 /sys/module/mali/parameters/mali_pp_scheduler_balance_jobs
  $B chmod 644 /sys/module/mali/parameters/mali_pp_scheduler_balance_jobs
  $B echo 1 > /sys/module/mali/parameters/mali_pp_scheduler_balance_jobs
 fi;
fi;
$B mount -t debugfs debugfs /sys/kernel/debug
$B chmod 777 /dev/graphics/fb0
if [ -e /sys/kernel/debug/msm_fb/0/vsync_enable ]; then
 $B echo "Disabling VSYNC.." >> $LOG
 $B echo 0 > /sys/kernel/debug/msm_fb/0/vsync_enable
fi;
if [ -e /sys/devices/platform/kgsl/msm_kgsl/kgsl-3d0/io_fraction ]; then
 $B echo 50 > /sys/devices/platform/kgsl/msm_kgsl/kgsl-3d0/io_fraction
 $B echo "KGSL tune-up.." >> $LOG
fi;
if [ -e /system/engine/prop/firstboot ]; then
 if [ -e /system/xbin/sqlite3 ]; then
  $B echo "Tuning Android animations.." >> $LOG
  $B echo "REPLACE INTO \"system\" VALUES(26,'window_animation_scale','0.25');REPLACE INTO \"system\" VALUES(27,'transition_animation_scale','0.25');" | sqlite3 /data/data/com.android.providers.settings/databases/settings.db
 fi;
fi;
if [ -e /sys/module/tpd_setting/parameters/tpd_mode ]; then
 $B chmod 644 /sys/module/tpd_setting/parameters/tpd_mode
 $B echo 1 > /sys/module/tpd_setting/parameters/tpd_mode
 $B echo "TPD tune-up.." >> $LOG
elif [ -e /sys/module/hid_magicmouse/parameters/scroll_speed ]; then
 $B chmod 644 /sys/module/hid_magicmouse/parameters/scroll_speed
 $B echo 63 > /sys/module/hid_magicmouse/parameters/scroll_speed
 $B echo "HID-magic tune-up" >> $LOG
fi;
if [ "$ARCH" == "armv6l" ]; then
 $B echo "No hard tuning for ARMv6 yet.." >> $LOG
else
 $B echo "Tuning Android graphics.." >> $LOG
 if [ -e /system/lib/libC2D2.so ]; then
  if [ "$SDK" -gt "10" ]; then
   setprop debug.composition.type c2d
   $B echo "C2D composition.." >> $LOG
  fi;
 elif [ -e /system/lib/egl/libGLESv2_adreno200.so ]; then
  setprop debug.composition.type mdp
  setprop debug.mdpcomp.logs 0
  setprop debug.mdpcomp.maxlayer 3
  setprop debug.mdpcomp.idletime -1
  $B echo "MDP composition.." >> $LOG
 else
  setprop debug.composition.type gpu
  $B echo "GPU composition.." >> $LOG
 fi;
 setprop debug.sf.hw 1
 setprop debug.egl.hw 1
 setprop debug.egl.swapinterval 1
 setprop debug.gr.swapinterval 1
 setprop debug.gr.numframebuffers 3
 setprop persist.sys.ui.hw 1
 setprop video.accelerate.hw 1
 setprop windowsmgr.max_events_per_sec 90
 setprop windowsmgr.support_rotation_270 true
 setprop hwui.render_dirty_regions false
 setprop debug.hwui.render_dirty_regions false
 setprop persist.sys.scrollingcache 3
 setprop ro.media.dec.jpeg.memcap 8000000
 setprop ro.media.enc.hprof.vid.bps 8000000
 setprop ro.media.enc.jpeg.quality 100
 setprop touch.presure.scale 0.1
 setprop ro.floatingtouch.available 1
 setprop ro.min.fling_velocity 9000
 setprop ro.max.fling_velocity 12000
 setprop persist.sys.strictmode.disable true
 setprop vidc.debug.level 0
 setprop ro.camera.sound.forced 0
fi;
TIME=$($B date | $B awk '{ print $4 }')
$B echo "[$TIME] 006 - ***GPU gear*** - OK" >> $LOG
sync;
