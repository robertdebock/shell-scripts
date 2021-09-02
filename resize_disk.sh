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

check_vg_space() {
  # Function to return free space on a vg
  free_extends=$(vgs ${vg} -o vg_free --noheading)
  if [ ${free_extends} -gt 0 ] ; then
    echo "YES, we can extend."
    return
  else
    echo "NO, This VG has no free space."
    return 1
  fi
}

extend_logical_volume() {
  # A function to extend a volume.
  :
}

resize_filesystem() {
  # A function to resize a given filesystem.
  :
}

find_disks && read disk_to_extend
find_volume_information
check_vg_space && extend_logical_volume && resize_filesystem

# TODO:
# 1. Don't resize to 100%, rather ask the user.
# 2. Write report if no free extends.
