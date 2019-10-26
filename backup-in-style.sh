#!/bin/bash
##
##################################################################################
## backup-in-style.sh								##
## Version - 1.06.46								##
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
## Assigning values to the variables created.
###

###
## The Locations of the Commands.
#

WHICH_CMD=`which which`
FIND_CMD=`"${WHICH_CMD}" find`
XARGS_CMD=`"${WHICH_CMD}" xargs`
TAR_CMD=`"${WHICH_CMD}" tar`
SCP_CMD=`"${WHICH_CMD}" scp`
GZIP_CMD=`"${WHICH_CMD}" gzip`
CP_CMD=`"${WHICH_CMD}" cp`
ECHO_CMD=`"${WHICH_CMD}" echo`


###
## Assigning Names for the Backup Files
#

FILES_TO_BACKUP=$(date +%d-%m-%Y)-IMP_FILES
FULL_BACKUP=${1:-$FILES_TO_BACKUP}


###
## Creating the selection menu.
###

###
## Main Selection Menu.
#

$ECHO_CMD -e "\n\t###################"
$ECHO_CMD -e "\t# BACKUP IN STYLE #"
$ECHO_CMD -e "\t###################\n\n"
$ECHO_CMD -e "\t1 - Backup a File"
$ECHO_CMD -e "\t2 - Backup aDirectory"
$ECHO_CMD -e "\tQ - Exit Program"
$ECHO_CMD -e "\n\n"
read -p "-> " SELECTION

case $SELECTION in
	1)
		$ECHO_CMD -e "\n\tCompression of the file will start immediately after pressing enter."
		$ECHO_CMD -e "\n\tPlease enter the name of the file you want to backup."
		$ECHO_CMD -e "\tExample: Use absolute paths: /path/to/file"
		read -p "-> " FILENAME
		
		$ECHO_CMD -e "\n\tPreparing the backup. This will take some time ..."
		$TAR_CMD -cvf $FULL_BACKUP.tar $FILENAME > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"tar\". Exiting.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tCompressing with \"gzip\".\n"
		$GZIP_CMD $FULL_BACKUP.tar > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"gzip\". Exiting.\n\n"
			exit 1;
		fi
		;;
	2)
		$ECHO_CMD -e "\n\tCompression of the directory will start immediately after pressing enter."
		$ECHO_CMD -e "\tPlease enter the name of the directory you want to backup."
		$ECHO_CMD -e "\tExample: Use absolute paths: /path/to/directory "
		read -p "-> " DIRNAME
		
		$ECHO_CMD -e "\n\tPlease enter the name of the directory you want to ignore."
		$ECHO_CMD -e "\tExample: Use absolute paths: /path/to/ignore/directory "
		$ECHO_CMD -e "\tLeave blank if no directory is to be ignored."
		read -p "-> " IGNOREDIR
		
		$ECHO_CMD -e "\n\tPreparing the backup. This will take some time ..."
		$FIND_CMD $DIRNAME -mtime -1 -type f -path $IGNOREDIR -prune -o -print0 | $XARGS_CMD -0 $TAR_CMD -rvf "$FULL_BACKUP.tar" > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"find\". Exiting.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tCompressing with \"gzip\"."
		$GZIP_CMD $FULL_BACKUP.tar > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"gzip\". Exiting.\n\n"
			exit 1;
		fi
		;;
	'Q')
		;&
	'q')
		$ECHO_CMD -e "\n\tExit Program\n\n"
		exit 1;
		;;
	*)
		$ECHO_CMD -e "\n\tUnknown character entered. Exiting!\n\n"
		exit 1;
		;;
esac

$ECHO_CMD -e "\n\tFinished compression of Backup!\n\n"

###
## Secondary Selection Menu
###

###
## Select Storage Location.
#

$ECHO_CMD -e "\n\t###################"
$ECHO_CMD -e "\t# BACKUP IN STYLE #"
$ECHO_CMD -e "\t###################\n"
$ECHO_CMD -e "\tPlease enter the storage location from the following options."
$ECHO_CMD -e "\t1 - External Hard Drive or USB Drive "
$ECHO_CMD -e "\t2 - Use \"scp\" if you want to create a copy of the backup and sent it securely to a remote server."
$ECHO_CMD -e "\tQ - Exit Program"
read -p "-> " CHOICE

case $CHOICE in
	1)
		$ECHO_CMD -e "\n\tEnter the storage location for the USB drive or external HD."
		$ECHO_CMD -e "\tExample: Use absolute paths: /path/to/USBDRIVE, /path/to/ExternalHD "
		read -p "-> " STORAGE
		
		$ECHO_CMD -e "\n\tTransfering the copy of the backup to storage location. This will take some time ..."
		$CP_CMD $FULL_BACKUP.tar.gz $STORAGE > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"cp\" or storage location.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tSuccessful transfer of backup to storage location.\n\n"
		;;
	2)
		## ***NOTE***
		## Before using this option please edit the command for "scp" so that it
		## matches your true location of the ssh server and add additional options
		## if needed. Thank you.
		## If you don't understand how to use ssh or scp please go to their
		## respective, current, and up-to-date manual pages for information.
		## You can also use "sftp" (Secure File Transport Protocol) if you prefer.
		
		$ECHO_CMD -e "\n\tYou are using \"scp\" to create a copy of the backup to send to the SSH Server."
		$ECHO_CMD -e "\tPlease enter the IP address of the SSH Server in the following prompt."
		$ECHO_CMD -e "\tExample: xxx.xxx.xxx.xxx \n"
		read -p "-> " REMOTEIPADDR
		
		$ECHO_CMD -e "\n\tEnter the username of the remote SSH Server or the username to be used.\n"
		read -p "-> " USERNAME
		
		$ECHO_CMD -e "\n\tEnter the name of the directory (storage location) of the SSH Server."
		$ECHO_CMD -e "\tExample: /path/to/remote/directory \n"
		read -p "-> " REMOTEDIR
		
		$ECHO_CMD -e "\n\tReady to transfer the backup to the storage location."
		$SCP_CMD $FULL_BACKUP.tar.gz $USERNAME@$REMOTEIPADDR:$REMOTEDIR > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"scp\". Exiting.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tSecure transfer of backup has finished.\n\n"
		;;
	'Q')
		;&
	'q')
		$ECHO_CMD -e "\n\tExit Program\n\n"
		exit 1;
		;;
	*)
		$ECHO_CMD -e "\n\tUnknown character entered. Exiting.\n\n"
		exit 1;
		;;
esac
