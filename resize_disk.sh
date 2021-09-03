#!/bin/sh

check_root() {
  # A function to check if the program is running as root.
  # INPUT: nothing.
  # OUTPUT: exit if not root.
  if [ $EUID -ne 0 ]; then
     echo "This script must be run as root."
     exit 1
  fi
}

scan_scsi() {
  # A function to find all scsi hosts and scan them.
  for host in $(ls /sys/class/scsi_host) ; do
    echo "- - -" > /sys/class/scsi_host/${host}/scan
  done
}

find_disks() {
  # A function to find disks that are on LVM.
  # INPUT: nothing.
  # OUTPUT: variable: disks
  disks=$(mount | grep '^/dev/mapper' | awk '{ print $3 }')
  lines=$(echo ${disks} | wc -l)
  characters=$(echo ${disks} | wc -c)
  if [ "$lines" -lt 1 -a "$characters" -lt 2 ] ; then
    echo "No LVM disks found that can be extended."
    exit 1
  fi
}

ask_disk() {
  # A function to ask the user for a disk.
  # INPUT: nothing
  # OUTPUT: variable: disk_to_extend
  echo "What disk do you want to exend?"
  echo
  echo "Choose from these disks found:"
  echo
  echo "${disks}"
  echo
  echo -n "> "
  read disk_to_extend
  echo "${disks}" | grep "${disk_to_extend}" > /dev/null
  if [ $? -ne 0 ] ; then
    echo "The disk ${disk_to_extend} is not in:"
    echo
    echo "${disks}"
    echo
    echo "Please enter a disk from the list of available disks."
    exit 1
  fi
}
    
find_volume_information() {
  # A function to find a VG based on the mountpoint.
  mapper_path=$(findmnt --mountpoint ${disk_to_extend} --noheadings | awk '{ print $2}')
  vg=$(lvs ${mapper_path} -o vg_name --noheadings | awk '{ print $1}')
  lv=$(lvs ${mapper_path} -o lv_name --noheadings | awk '{ print $1}')
}

check_vg_space() {
  # Function to return free space on a vg
  available_megabytes=$(( 1 * $(vgs -o vg_free --noheading --units m | sed 's/.$//;s/\...$//') ))
  if [ ${available_megabytes} -lt 1 ] ; then
    echo "This VG has ${available_megabytes}MB free and can't be extended."
    echo
    echo "Please add a disk, and use these commands to add the disk to the volumegroup."
    echo "# Find the disk using \`dmesg\`, for example \"/dev/sdb\"."
    echo "vgextend ${vg} /dev/sdb"
    echo
    exit 1
  fi
  available_gigabytes=$(( "${available_megabytes}" / 1024 ))
}

ask_extend() {
  # A function to ask the user how much space to extend a volume with.
  echo "How much space would you like to add? There is ${available_gigabytes}GB available."
  echo ""
  echo "Use these quantifiers to express the size."
  echo "M = Megabyte"
  echo "G = Gigabyte"
  echo "T = Terrabyte"
  echo ""
  echo "For example \"512M\" is a valid answer."
  echo ""
  echo -n "> "
  read extend_size
  digit=$(echo "${extend_size}" | sed 's/.$//')
  if ! [ -n "${digit}" -a "${digit}" -eq "${digit}" ] 2> /dev/null ; then
    echo "Digit ${digit} is not valid."
    echo
    echo "Please us a digit like \"1\" or \"512\"."
    exit 1
  fi
  digit=$(( "${digit}" * 1 ))
  quantifier=$(echo "${extend_size: -1}")
  case "${quantifier}" in
    M)
      extend_size_gigabytes="$(( ${digit} / 1024 ))"
    ;;
    G)
      extend_size_gigabytes="${digit}"
    ;;
    T)
      extend_size_gigabytes="$(( ${digit} * 1024 ))"
    ;;
    *)
      echo "Quantifier ${quantifier} is not valid."
      echo
      echo "Please use a quantifier as \"M\",\"G\" or \"T\"."
      exit 1
    ;;
  esac
  if [ "${available_gigabytes}" -lt "${extend_size_gigabytes}" ] ; then
    echo "You are requesting more space (${extend_size_gigabytes}GB) than there is available (${available_gigabytes}GB)."
    exit 1
  fi
}

extend_logical_volume() {
  # A function to extend a volume.
  echo "Resizing logical volume: /dev/${vg}/${lv}"
  lvextend -L +${digit}${quantifier} /dev/"${vg}"/"${lv}" > /dev/null
}

discover_filesystem_type() {
  # A function to figure out what filesystem is being used.
  output=$(file -Ls /dev/"${vg}"/"${lv}")
  for filesystem in ext3 ext4 XFS ; do
    echo "${output}" | grep "${filesystem}" > /dev/null
    if [ $? = 0 ] ; then
      filesystem_type="${filesystem}"
    fi
  done
}

resize_filesystem() {
  # A function to resize a given filesystem.
  echo "Resizing filesystem ${disk_to_extend}."
  case "${filesystem_type}" in
    ext3|ext4)
      resize2fs /dev/"${vg}"/"${lv}" > /dev/null 2>&1
    ;;
    XFS)
      xfs_growfs "${disk_to_extend}" > /dev/null
    ;;
    *)
      echo "The filesystem type ${filesystem_type} can't be extended using this script."
      exit 1
    ;;
  esac
}

check_root
scan_scsi
find_disks
ask_disk
find_volume_information
check_vg_space
ask_extend
extend_logical_volume && discover_filesystem_type && resize_filesystem
