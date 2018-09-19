#!/bin/bash
#Description: Checking server hardware information
#KeepWalking86

#Date format
NOW=$(date +"%d-%m-%Y")
# create output file name
OUTPUT="sysinfo.$NOW.log"
# Assign the fd 3 to $OUTPUT file
exec 3> $OUTPUT

#Check user account to run script
USER=$UID
if [ $USER != 0 ]; then
	echo "Require root account to run script"
	exit 1;
fi

#Installing required tools
if [ -f /etc/debian_version ]; then
	apt-get install lsb_release lspci -y
else
	if [ -f /etc/redhat-release ]; then
		yum -y install redhat-lsb-core pciutils
	else
		echo "Distro hasn't been supported by this script"
		exit 1;
	fi
fi
# Print date and hostname
echo "---------------------------------------------------" >&3
echo "Script run @ $(date) on $(hostname)" >&3
echo "---------------------------------------------------" >&3

echo "---------------------------------------------------" >&3
echo "**********OS Information*************" >&3
#lsb_release -a |grep Description >&3 
hostnamectl >&3

echo "---------------------------------------------------" >&3
echo "*****Manufacturer - Product Name*****" >&3
dmidecode | grep -A3 '^System Information' >&3


#CPU information
echo "---------------------------------------------------" >&3
echo "**********CPU Information*************" >&3
dmidecode -t processor | grep -i version >&3
#grep 'model name' /proc/cpuinfo | uniq | awk -F: '{ print $2}' >&3
#CPU cache layer
dmidecode -t processor | grep -i cache >&3
#Core & Thread
dmidecode -t processor  | grep -i count >&3


echo "---------------------------------------------------" >&3
echo "**********Memory Information*************" >&3
#Number Of Devices (RAM slots)
echo "Max devices & capacity" >&3
dmidecode -t memory | grep -i "Number of devices" >&3
#Maximum Capacity
dmidecode -t memory | grep -i "Maximum" >&3
#RAM device size
echo "***RAM devices size installed***: " >&3
dmidecode -t 'memory' | grep -i "size" | grep -i 'mb' >&3
#RAM speed by Mhz
dmidecode -t memory | grep -i "speed" >&3
#Memory Total & Free
#grep -i 'memtotal' /proc/meminfo >&3 
grep -e MemTotal -e MemAvailable /proc/meminfo >&3


#Main Board inforation
echo "---------------------------------------------------" >&3
echo "*********Main Board Information*********" >&3
dmidecode -t baseboard >&3

#Network card information
echo "---------------------------------------------------" >&3
echo "*******Network device information*******" >&3
lspci | egrep -i 'network|ethernet' >&3

#Raid information
echo "---------------------------------------------------" >&3
echo "*******Raid information*******" >&3
lspci -vv | grep -i raid >&3

#Hard disk
echo "---------------------------------------------------" >&3
echo "*******Hard disk information" >&3
#lsblk -o "NAME,MAJ:MIN,RM,SIZE,RO,FSTYPE,MOUNTPOINT,UUID" >&3
lshw -class disk >&3
