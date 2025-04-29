#!/usr/bin/bash
##

###
## Commands for the script to function.
###

###
## Searches for the commands which help to compress, archive, and remotely transfer your data.
#

LST_CMDS=( "tar" "zstd" "ssh" "scp" )

if cmds in "${LST_CMDS[@]}";
do
	if ! command -v "$cmds" > /dev/null 2>&1;
	then
		echo "$cmds not found"
		echo "Please install the corresponding packages."
		exit 0
	fi
done


###
## Configuring the values into the variables.
###

###
## Locations of the commands to be used.
#

CMDFIND=`/usr/bin/find`
CMDXARGS=`/usr/bin/xargs`
CMDTAR=`/usr/bin/tar`
CMDSCP=`/usr/bin/scp`
CMDZSTD=`/usr/bin/zstd`
CMDCP=`/usr/bin/cp`
CMDECHO=`/usr/bin/echo`
CMDSSH=`/usr/bin/ssh`


###
## Assigning Names for the Backup Files
#

USR=$( whoami )
HOST=$( uname -n )
TIMESTAMP=$(date +%d%m%Y-%H%M%S)
ARCHIVE_BACKUP=${USR}-${HOST}-${TIMESTAMP}
FULL_BACKUP=${1:-$ARCHIVE_BACKUP}


###
## Display a Usage Message.
###

###
## Display a usage message.
#

displayUsage ()
{
	echo -e "Usage: ./$basename"
	echo -e "Use absolute paths: /path/to/file"
}

	
###
## Display a Title
###

###
## Display the name of the script.
#

$CMDECHO -e "\n\t "
$CMDECHO -e "\t>>> { Backup In Style } <<<"
$CMDECHO -e "\t \n\n"


###
## Choose a file or directory to archive and compress.
###

###
## Choose a file or directory to archive.
#

read -p "Choose a file or directory to archive: " FILENAME


###
## Input validation
#

if [ ! -e "$FILENAME" ];
then
	echo "Unknown file or directory: Does not exist."
	displayUsage
	exit 1
fi


###
## Creating the backup archive.
#

$CMDECHO -e "\nPreparing backup. This will take some time ..."
$CMDTAR -cvf $FULL_BACKUP.tar $FILENAME > /dev/null 2>&1


###
## Display an error message.
#

if [ $? -ne "0" ];
then
	$ECHO_CMD -e "\nAn error has occurred during the backup process.\n\n"
	exit 1;
fi


##FIXME: Make use of the zstd command for the next stage.
		
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


###
###
###

$ECHO_CMD -e "\n\tBackup has finished!\n\n"

###
## Secondary Selection Menu
###

###
## Select Storage Location.
#

$ECHO_CMD -e "\n\t######################################"
$ECHO_CMD -e "\t# You are now using: Backup In Style #"
$ECHO_CMD -e "\t######################################\n\n"
$ECHO_CMD -e "\tPlease enter the storage location from the following options.\n"
$ECHO_CMD -e "\t1 - External Hard Drive or USB Drive\n"
$ECHO_CMD -e "\t2 - Send to a secure remote server using SSH.\n"
$ECHO_CMD -e "\tQ - Exit Program\n\n"

read -p "-> " CHOICE

case $CHOICE in
	1)
		$ECHO_CMD -e "\n\tEnter the storage location for the USB drive or external HD.\n"
		$ECHO_CMD -e "\tExample: Use absolute paths: /path/to/USBDRIVE, /path/to/ExternalHD\n"
		read -p "-> " STORAGE
		
		$ECHO_CMD -e "\n\tTransfering the backup data to the storage location. This will take some time ...\n"
		$CP_CMD $FULL_BACKUP.tar.gz $STORAGE > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"cp\" or storage location.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tYour data has been successfuly transfered.\n\n"
		;;
	2)
		## ***NOTE***
		## Please use the correct IP Addresses of the SSH server you are trying
		## to connect. Edit the command to add additional options if needed.
		## Thank you.
		## If you don't understand how to use ssh or scp please go to their
		## respective and up-to-date manual pages for information.
		
		$ECHO_CMD -e "\n\tThank you for choosing the secure way of transfering your data.\n"
		$ECHO_CMD -e "\tPlease enter the IP address of the SSH Server in the following prompt.\n"
		$ECHO_CMD -e "\tExample: xxx.xxx.xxx.xxx \n"
		read -p "-> " REMOTEIPADDR
		
		$ECHO_CMD -e "\n\tEnter the username of your choice.\n"
		read -p "-> " USERNAME
		
		$ECHO_CMD -e "\n\tEnter the name of the remote directory (storage location) of the SSH Server.\n"
		$ECHO_CMD -e "\tExample: /path/to/remote/directory \n"
		read -p "-> " REMOTEDIR
		
		$ECHO_CMD -e "\n\tYour backup data is ready to be transfered.\n"
		$SCP_CMD $FULL_BACKUP.tar.gz $USERNAME@$REMOTEIPADDR:$REMOTEDIR > /dev/null 2>&1
		if (( "$?" != "0" ))
		then
			$ECHO_CMD -e "\n\tError! Check the command syntax for \"scp\". Exiting.\n\n"
			exit 1;
		fi
		
		$ECHO_CMD -e "\n\tSecure transfer of your data has finished.\n\n"
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
