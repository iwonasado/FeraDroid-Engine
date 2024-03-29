#!/system/bin/sh
### FeraDroid Engine v0.19 | By FeraVolt. 2015 ###
B=/system/engine/bin/busybox
LOG=/sdcard/Android/FDE.txt
TIME=$($B date | $B awk '{ print $4 }')
$B echo "[$TIME] 004 - ***Memory gear***" >> $LOG
RAM=$($B free -m | $B awk '{ print $2 }' | $B sed -n 2p)
SWAP=$($B free -m | $B awk '{ print $2 }' | $B sed -n 4p)
KB=$((RAM*5))
AA="/sys/block/*"
BB="/sys/devices/virtual/block/*"
MMC="/sys/block/mmc*"
MTD="/sys/block/mtd*"
$B echo "Device has $RAM MB of RAM and $SWAP MB of SWAP/ZRAM" >> $LOG
$B echo "Calculated readahead parameter is $KB KB" >> $LOG
if [ -e /mnt/sd-ext ]; then
 $B echo "Trying to mount SD-EXT partition if it exists.." >> $LOG
 $B mount -t ext3 -o rw /dev/block/vold/179:2 /mnt/sd-ext
 $B mount -t ext3 -o rw /dev/block/mmcblk0p2 /mnt/sd-ext
 $B sleep 1
 $B mount -t ext4 -o rw /dev/block/vold/179:2 /mnt/sd-ext
 $B mount -t ext4 -o rw /dev/block/mmcblk0p2 /mnt/sd-ext
 $B sleep 1
fi;
if [ -e /storage/extSdCard ]; then
 $B echo "Trying to mount extSdCard partition if it exists.." >> $LOG
 $B mount -t ext3 -o rw /dev/block/mmcblk1p1 /storage/extSdCard
 $B sleep 1
 $B mount -t ext4 -o rw /dev/block/mmcblk1p1 /storage/extSdCard
 $B sleep 1
fi;
for x in $($B mount | grep ext2 | cut -d " " -f3);
do
 $B mount -o remount,noatime,nodiratime,data=writeback,rw "${x}"
 $B echo "Remounting EXT2 partitions.." >> $LOG
done;
for x in $($B mount | grep ext3 | cut -d " " -f3);
do
 $B mount -o remount,noatime,nodiratime,data=writeback,rw "${x}"
 $B echo "Remounting EXT3 partitions.." >> $LOG
done;
for x in $($B mount | grep ext4 | cut -d " " -f3);
do
 $B mount -o remount,noatime,delalloc,nosuid,nodev,nodiratime,barrier=0,nobh,commit=90,discard,data=writeback,rw "${x}"
 $B echo "Remounting EXT4 partitions.." >> $LOG
done;
for i in $AA $BB; do
if [ -e "${i}"/queue/read_ahead_kb ]; then
 $B echo "Applying new I/O parameters.." >> $LOG
 $B echo $KB > "${i}"/queue/read_ahead_kb
 $B echo $KB > "${i}"/bdi/read_ahead_kb
 $B echo 0 > "${i}"/queue/iostats
 $B echo 0 > "${i}"/queue/rotational
 $B echo 1 > "${i}"/queue/rq_affinity
 $B echo 1 > "${i}"/queue/nomerges
fi;
done;
for b in $MMC $MTD; do
if [ -e "${b}"/queue/add_random ]; then
 $B echo "Applying new rnd parameters.." >> $LOG
 $B echo 0 > "${b}"/queue/add_random
fi;
done;
CHK=$($B cat /sys/devices/virtual/bdi/179:0/read_ahead_kb)
$B echo "Checking. Current parameter is $CHK KB" >> $LOG
TIME=$($B date | $B awk '{ print $4 }')
$B echo "[$TIME] 004 - ***Memory gear*** - OK" >> $LOG
sync;
