#!/bin/bash
##
##################################################################################
## backup-in-style.sh								##
## Version - 0.03.36								##
##										##
## Description:									##
##	This script lets you create a backup with the most recently		##
##	modified files. After compressing the files it asks you 		##
##	where you want to transfer your backup. To a USB drive, 		##
##	an external hard drive, or a remote server.				##
##										##
## Copyright (C) 2019 Joel Vazquez Ortiz					##
##										##
## GPL - General Public License							##
##										##
## This program is free software; you can redistribute it and/or modify		##
## it under the terms of the GNU General Public License as published by		##
## the Free Software Foundation; either version 3 of the license , or		##
## (at your option) any later version.						##
##										##
## This program is distributed in the hope that it will be useful		##
## but WITHOUT ANT WARRANTY; without even implied warranty of			##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			##
## GNU General Public License for more details.					##
##										##
## You should have received a copy of the GNU General Public License		##
## along with this program; if not write to the Free Software			##
## Foundation, Inc., 59 Temple Place - Suite 330,				##
## Boston, MA 02111-1307, USA.							##
##										##
##################################################################################


###
## Variables
#

FILES_TO_BACKUP=$(date +%d-%m-%Y)-IMP_FILES
FULL_BACKUP=${1:-$FILES_TO_BACKUP}


###
## Choose the directory to save.
#

echo -e "\n\tPlease enter the directory name to create the backup."
echo -e "\tExample: Use Absolute path: /path/to/files/to/backup "
read -p "-> " backup


###
## Choose what directory to ignore.
#

echo -e "\n\tPlease enter the directory name to ignore."
echo -e "\tExample: Use Absolute Paths:  /path/to/ignore/directory"
echo -e "\tLeave blank if no directory is to be ignored."
read -p "-> " ignore


###
## Compress the backup.
#

echo -e "\n\tPreparing the backup."
echo -e "\tCompression of backup has started. This will take some time..."
find $backup -mtime -1 -type f -path $ignore -prune -o -print0 | xargs -0 tar -rvf "$FULL_BACKUP.tar" > /dev/null 2>&1
gzip $FULL_BACKUP.tar > /dev/null 2>&1
if (( "$?" != "0" ));
then
	echo -e "\n\tError! Check the command syntax for \"gzip\". Exiting."
	exit 1;
fi
echo -e "\n\tFinished compression of backup.\n\n"


###
## Storage Location.
#

echo -e "\n\tPlease enter the storage location from the following options."
echo -e "\t1 - External Hard Drive or USB Drive"
echo -e "\t2 - Remote Server"
read -p "-> " choice

case $choice in
	1)
		echo -e "\n\tEnter the storage location."
		echo -e "\tExample: Use Absolute Paths: /path/to/USB, /path/to/ExternalHD"
		read -p "-> " storage

		echo -e "\n\tTransfering copy of backup archive to storage location."
		cp $FULL_BACKUP.tar.gz $storage > /dev/null 2>&1
		if (( "$?" != "0" ));
		then
			echo -e "\n\tError! Check command syntax for \"cp\" or storage location.\n\n"
			exit 1;
		fi
		echo -e "\n\tSuccessful transfer of backup to storage location.\n\n"
		;;
	2)
		# ****NOTE****
		# Before using this option please edit the command for scp so that it
		# matches your true location of the ssh server. Thank you.
		# If you don't understand how to use ssh or scp please go to their 
		# respective, current and up-to-date manual pages for information.
		# You can also use "sftp" (Secure File Transport Protocol) if you prefer.

		echo -e "\n\tThe SSH server will be used to transfer your backup."
		echo -e "\tPlease enter the IP Address of the SSH server in the following prompt."
		read -p "-> " ipaddr

		echo -e "\n\tEnter the username of the remote SSH server."
		read -p "-> " username

		echo -e "\n\tEnter the name of the directory (storage location) of the SSH server."
		read -p "-> " remotedir

		echo -e "\n\tReady to transfer the backup to the storage location."
		scp $FULL_BACKUP.tar.gz $username@$ipaddr:$remotedir > /dev/null 2>&1
		if (( "$?" != "0" ));
		then
			echo -e "\n\tError! Check command syntax for \"scp\" and check the IP Address if it is correct.\n\n"
			exit 1;
		fi
		echo -e "\n\tFinished transfer of backup."
		;;
	*)
		echo -e "\n\tError! Unknown character entered. Exiting program.\n\n"
		exit 1;
		;;
esac
