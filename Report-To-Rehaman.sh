#!/bin/bash

#set -x

# Note: Based on CloverPackage MountESP script.

if [ "$(id -u)" != "0" ]; then
    echo "This script requires superuser access, use: 'sudo $0 $@'"
    exit 1
fi

if [ "$1" == "" ]; then
    DestVolume=/
else
    DestVolume="$1"
fi
DiskDevice=$(LC_ALL=C diskutil info "$DestVolume" 2>/dev/null | sed -n 's/.*Part [oO]f Whole: *//p')
if [ -z "$DiskDevice" ]; then
    echo "Can't find volume with the name $DestVolume"
    exit 1
fi

# Check if the disk is a GPT disk
PartitionScheme=$(LC_ALL=C diskutil info "$DiskDevice" 2>/dev/null | sed -nE 's/.*(Partition Type|Content \(IOContent\)): *//p')
if [ "$PartitionScheme" != "GUID_partition_scheme" ]; then
    echo Error: volume $DestVolume is not on GPT disk
    exit 1
fi

# Get the index of the EFI partition
EFIIndex=$(LC_ALL=C /usr/sbin/gpt -r show "/dev/$DiskDevice" 2>/dev/null | awk 'toupper($7) == "C12A7328-F81F-11D2-BA4B-00A0C93EC93B" {print $3; exit}')
[ -z "$EFIIndex" ] && EFIIndex=$(LC_ALL=C diskutil list "$DiskDevice" 2>/dev/null | awk '$2 == "EFI" {print $1; exit}' | cut -d : -f 1)
[ -z "$EFIIndex" ] && EFIIndex=$(LC_ALL=C diskutil list "$DiskDevice" 2>/dev/null | grep "EFI"|awk '{print $1}'|cut -d : -f 1)
[ -z "$EFIIndex" ] && EFIIndex=1 # if not found use the index 1

# Define the EFIDevice
EFIDevice="${DiskDevice}s$EFIIndex"

# Get the EFI mount point if the partition is currently mounted
EFIMountPoint=$(LC_ALL=C mount | grep "$EFIDevice on" | cut -f 3 -d ' ')

code=0
if [ ! "$EFIMountPoint" ]; then
    # try to mount the EFI partition
    EFIMountPoint="/Volumes/EFI"
    [ ! -d "$EFIMountPoint" ] && mkdir -p "$EFIMountPoint"
    mount -t msdos /dev/$EFIDevice "$EFIMountPoint" >/dev/null 2>&1
    code=$?
fi
echo $EFIMountPoint
#Added By Mo7a 1995 To make 75% of Problem Reporting easy .
rm -Rf  ~/Desktop/Problem_Reporting
mkdir ~/Desktop/Problem_Reporting
cp -r /Volumes/EFI/EFI/Clover/* ~/Desktop/Problem_Reporting
rm -r ~/Desktop/Problem_Reporting/themes
mkdir ~/Desktop/Problem_Reporting/PatchMatic
cd ~/Desktop/Problem_Reporting/PatchMatic 
 patchmatic -extract 

echo "kextstat" >> ~/Desktop/Problem_Reporting/TerminalOutput
kextstat|grep -y acpiplat >> ~/Desktop/Problem_Reporting/TerminalOutput
kextstat|grep -y appleintelcpu >> ~/Desktop/Problem_Reporting/TerminalOutput
kextstat|grep -y applelpc >> ~/Desktop/Problem_Reporting/TerminalOutput
kextstat|grep -y applehda >> ~/Desktop/Problem_Reporting/TerminalOutput
echo "APPLE HDA"
ls -l /System/Library/Extensions/AppleHDA.kext/Contents/Resources/*.zml* >> ~/Desktop/Problem_Reporting/TerminalOutput
echo "kextcache"
touch /System/Library/Extensions && sudo kextcache -u / >> ~/Desktop/Problem_Reporting/TerminalOutput

 
exit $code
