#!/bin/sh -x

find_disks() {
  # A function to find disks that are on LVM.
  disks=$(mount | grep '^/dev/mapper' | awk '{ print $3 }')
  lines=$(echo ${disks} | wc -l)
  characters=$(echo ${disks} | wc -c)
  if [ "$lines" -gt 0 -a "$characters" -gt 1 ] ; then
    echo "What disk do you want to exend?"
    echo
    echo "${disks}"
    return
  else
    echo "No LVM disks found that can be extended."
    return 1
  fi
}

find_volume_information() {
  # A function to find a VG based on the mountpoint.
  mapper_path=$(findmnt --mountpoint $(disk_to_extend) --noheadings | awk '{ print $2}')
  vg=$(lvs ${mapper_path} -o vg_name --noheadings)
  lv=$(lvs ${mapper_path} -o lv_name --noheadings)
}

# scan_scsi
#
# check_vg_space
# space: resize_lv
# no_space: "Please resize the disk."
#
# resize_lv() {
# find_free_space_on_vg
# echo "How much space do you want to extend the disk with? (between x and y)"
# lvextend ...
#

find_disks && read disk_to_extend
find_volume_information
