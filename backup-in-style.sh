#!/bin/bash

###
## Configuring the values into the variables.
###

###
## Locations of the commands to be used.
#

CMDFIND=/usr/bin/find
CMDXARGS=/usr/bin/xargs
CMDTAR=/usr/bin/tar
CMDSCP=/usr/bin/scp
CMDZSTD=/usr/bin/zstd
CMDCP=/usr/bin/cp
CMDSSH=/usr/bin/ssh


###
## Assigning Names for the Log Directory and File
##

###
## Location to log file
#

LOGFILE="backupstyle.log"
LOGDIR="/var/log/backupstyle.d"


###
## Assigning Names for the Backup Files
###

###
## Display the username and the host of the machine.
#

USR=$( whoami )
HOST=$( uname -n )


###
## Variable names for Incremental Backups
#

WEEKDAY_NAME=$( date +%a )
INCREMENTAL_BACKUP=${USER}-${HOST}-INCREMENTAL-${WEEKDAY_NAME}-${TIMESTAMP}


###
## Create Temporary Directory to Save the Compressed Files.
#

TMPDIR="TempBK"

###
## Error Handling
###

###
## Show error status and exit
##TODO: Make sure to test these functions. Also, log these error messages to a file.

trap 'exit_error $? $LINENO' ERR

exit_error ()
{
	E_STAT=$1
	LINE_NO=$2
	E_MSG="$( date +%c ): $( uname -n ): ERROR: [$E_STAT] occurred on line $LINE_NO\n"

	printf "%b" "$E_MSG" | tee >> "${LOGDIR}/${LOGFILE}"
	exit $E_STAT
}


###
## Log Successful Messages Function
##NOTE: You can create two different functions to display a successful message when compression is finished
##	and when the transfer completes.

successMessage ()
{
	S_MSG="$( date +%c ): $( uname -n ): SUCCESS: Data compression and transfer successful.\n"

	printf "%b" "$S_MSG" | tee >> "${LOGDIR}/${LOGFILE}"
}


###
## Function which display an error message if the IP address was entered incorrectly.
##FIXME: Make this POSIX complaint.

function validIP()
{
	case "$*" in
		""|*[!0-9.]*|*[!0-9])
			return 1
			;;
	esac

	local IFS=.

	set -- $*

	[ $# -eq 4 ] && [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] && \
		[ ${3:-666} -le 255 ] && [ ${4:-666} -le 254 ]
}


###
## Display a Title
###

###
## The function which displays the title of the script.
##TODO: Choose at random which ascii art to display.
##NOTES: Ideas: Use /dev/urandom or the rand() maybe can help you choose a file.
##	 Use an array for a list of filenames.
##	 Use a 'for' loop.
##	 Use globbing.

ASCIILOC="/usr/share"
BKDIR="backupstyle"
ASCIIDIR="asciiart"

asciiArt ()
{
	find ${ASCIILOC}/$BKDIR/$ASCIIDIR -maxdepth 1 -type f -print | sort -R | tail -n 1 | while read file ; do cat $file; done
}


###
## Function to Archive files
##TODO: Save the archives into a temporary directory.

if [ ! -d /tmp/$TMPDIR ]
then
	mkdir /tmp/$TMPDIR
else
	printf "$TMPDIR directory exists."
fi

compressFiles ()
{
	printf "Your files are being archived and compressed."
	printf "This will take a while . . "

	LIST_DIR=( "$DIRNAME"/* )
	COUNTER=1

	for files in ${LIST_DIR[@]}
	do
		TIMESTAMP=$( date +%Y%m%d-%H%M%S )
		BASE_NAME=$( basename "$files" )
		FULL_BACKUP=${BASE_NAME}-${USR}-${HOST}-FB-${TIMESTAMP}-$( printf "%03d" $COUNTER )

		${CMDTAR} -cf /tmp/$TMPDIR/$FULL_BACKUP.tar $files > /dev/null 2>&1
		
		${CMDZSTD} -z /tmp/$TMPDIR/$FULL_BACKUP.tar > /dev/null 2>&1

		(( COUNTER++ ))
	done

	printf "Finished compressing archives."
}


###
## Call Function to display ascii art.
#

clear

asciiArt


###
## Main Menu
###
##TODO: Configure the variables for each one.
###
## Menu to Choose Full Backup, Incremental Backups, Or Restore From Backups
#

while true
do
	## Primary Menu.
	PS3="Choose a Backup Method: "
	CHOICES=("Full" "Incremental" "Restore" "Quit")
	
	select OPT in "${CHOICES[@]}"
	do
		case $OPT in 
			"Full" )
				## Secondary Menu.
				PS3="Select the location to transfer your archives: "
				SELECTION=("SSH" "LOCAL" "QUIT")

				select CHOICE in "${SELECTION[@]}"
				do
					case $CHOICE in
						"SSH" )
							printf "Enter the destination directory for the ssh server: "

							read -p "-> " SSHSTORAGE

							printf "Enter the IP address of the ssh server: "

							read -p "-> " SSHIPADDR

							printf "Enter the username of the ssh server: "

							read -p "-> " SSHUSRNAME

							printf "Choose the files to backup: "

							read -p "-> " DIRNAME

							compressFiles

							## Temporary directory with all the compressed files.
							LIST_TMP=( "/tmp/$TMPDIR"/*.tar.zst )

							##NOTE: You can modify the SSH command according to your server configuration.
							for zst2BK in "${LIST_TMP[@]}"
							do
								${CMDSCP} $zst2BK scp://$SSHUSRNM@$SSHIPADDR/${SSHSTORAGE} > /dev/null 2>&1
							done

							rm /tmp/$TMPDIR/*

							rmdir /tmp/$TMPDIR

							successMessage
							;;
						"LOCAL" )
							printf "Enter the destination local directory: "

							read -p "-> " LOCALDIR

							printf "Choose the files to backup: "

							read -p "-> " DIRNAME

							compressFiles

							## Temporary directory with all the compressed files.
							LIST_TMP=( "/tmp/$TMPDIR"/*.tar.zst )

							for zst2BK in "${LIST_TMP[@]}"
							do
								${CMDCP} $zst2BK ${LOCALDIR} > /dev/null 2>&1
							done

							rm /tmp/$TMPDIR/*

							rmdir /tmp/$TMPDIR

							successMessage
							;;
						"QUIT" )
							printf "Exiting the script."
							break
							;;
						* )
							printf "Unknown choice"
							;;
					esac
				done
				;;
			"Incremental" )
				echo "You chose to do an Incremental backup."
				;;
			"Restore" )
				echo "You chose to restore from backup."
				;;
			"Quit" )
				echo "Exiting the script."
				;;
			* )
				echo "Unknown choice entered."
				;;
		esac
	done
done


#echo -e "Choose where to send files.\n"
#echo -e "\t1 - Local Drive\n"
#echo -e "\t2 - Remote SSH Server\n"
#echo -e "\tQ - Exit Program\n\n"

#read -p "-> " CHOICE

#case $CHOICE in
#	1)
#		read -p "Enter the location for the local drive. " STORAGE
		
		#if [ ! -d "${STORAGE}" ]
		#then
		#	err_File
		#fi

#		echo -e "\n\tTransfering...\n"
#		${CMDCP} ${FULL_BACKUP}.tar.zst ${STORAGE} > /dev/null 2>&1

		#if [ ${FULL_BACKUP##*.} != "zst" ]
		#if [ $? -ne "0" ]
		#then
		#	err_File
		#fi

#		echo -e "\nYour data has been successfuly transfered.\n\n"
#		;;
#	2)
#		read -p "Enter the IP address of the SSH server: " SSHIPADDR
		
#		if ! validIP "$SSHIPADDR"
#		then
#			echo -e "\033[0;31m$SSHIPADDR\033[0;0m: Invalid IP address: Make sure you entered the correct IP address."
#			exit 61
#		fi

#		read -p "Enter the username of the remote SSH server: " SSHUSRNM

#		read -p "Enter the location of the remote directory: " SSHSTORAGE
		
#		echo -e "\n\tYour data is ready to be transfered.\n"
#		${CMDSCP} ${FULL_BACKUP}.tar.zst scp://$SSHUSRNM@$SSHIPADDR/${SSHSTORAGE} > /dev/null 2>&1
		
		#if [ $? -ne "0" ];
		#then
		#	echo -e "Error [255]: Failed to connect to the SSH server.\n"
		#	echo -e "Make sure you are using the correct username.\n"
		#	echo -e "Check your network connection and server status.\n\n"
		#	exit 255
		#fi
		
#		echo -e "\n\tSecure transfer of your data has finished.\n\n"
#		;;
#	'Q')
#		;&
#	'q')
#		echo -e "\n\tExit Program\n\n"
#		exit 0;
#		;;
#	*)
#		echo -e "\n\tUnknown character entered. Exiting.\n\n"
#		exit 1;
#		;;
#esac

exit 0
