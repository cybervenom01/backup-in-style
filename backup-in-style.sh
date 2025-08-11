#!/bin/sh

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

LOGFILE="bkstyle.log"
LOGDIR="/var/log/bkstyle.d"


###
## Assigning Names for the Backup Files
###

###
## Variable names for Full Backup
#

USR=$( whoami )
HOST=$( uname -n )
TIMESTAMP=$( date +%Y%m%d-%H%M%S )
FULL_BACKUP=${USR}-${HOST}-FULL-BACKUP-${TIMESTAMP}


###
## Variable names for Incremental Backups
#

WEEKDAY_NAME=$( date +%a )
INCREMENTAL_BACKUP=${USER}-${HOST}-INCREMENTAL-${WEEKDAY_NAME}-${TIMESTAMP}


###
## Variable names for Local or Remote locations to transfer archives.
###

###
## Error Handling
###

###
## Show error status and exit
##TODO: Make sure to test these functions. Also, log these error messages to a file.

trap 'exit_error $? $LINENO' ERR

exit_error ()
{
	##NOTE: You might need to create these as global variables in case this function
	##	gives you an error.
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

ASCIIDIR="../ascii"

asciiArt ()
{
	find ${ASCIIDIR} -maxdepth 1 -type f -print | sort -R | tail -n 1 | while read file ; do cat $file; done
}


###
## Function to Archive files
##TODO: Choose files to archive.
##NOTE: You can also use this same function to compress the archives.

archiveFiles ()
{
	printf "Archiving files"
}


###
## Compressing Files
#

compressArchives ()
{
	printf "Compressing Archives"
}


###
## Call Function to display ascii art.
#

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
	printf "Choose a Backup Method: "
	printf "1 - Full Backup"
	printf "2 - Incremental Backup"
	printf "3 - Restore From Backup"
	printf "Q - Exit the Script"

	read -p "-> " BACKUP

	case $BACKUP in
		"1"	)
			##TODO: Choose the location where the files are to backup.
			##	Use an array with all the files and directories to archive.
			##	Choose destination directory to transfer archived files: 
			##		- Transfer to remote location: SSH
			##		- Transfer to local drive
			##	All files will be archived and compressed.
			##	All the archives will have a unique name with day of the week,
			##	and the time and date.
			##	All the compressed files will be transfered to the location
			##	chosen by the user.
			printf "You chose to do a Full Backup.\n\n"
			printf "Choose the directory for the files to backup: "

			read -p "-> " DIRNAME

			printf "You can leave this one empty if don't want to ignore any files or directories"
			printf "Choose which file or directory you don't want to backup: "
			
			read -p "-> " IGNOREFILE
			
			printf "Choose the location to transfer the archived files: "
			printf "1 - SSH\n"
			printf "2 - Local"

			read -p "-> " STORAGE
			
			case $STORAGE in
				"1" )
					echo "You have chosen to transfer your files to an SSH server."
					;;
				"2" )
					echo "You have chosen to transfer your files to a local drive."
					;;
				* )
					echo "Unknown location"
					;;
			esac
			;;
		"2"	)
			##TODO: Choose the file or directory you recently modified to archive.
			##	If the file has not been recently modified it will not be archived.
			##	Archive and compress the files.
			##	Choose a destination directory to transfer archived files:
			##		- Transfer to remote location: SSH
			##		- Transfer to local drive
			##	All the archives will have a unique name with day of the week,
			##	and the time and date.
			printf "You chose 2: Incremental Backup"
			;;
		"3"	)
			##TODO: Choose the archived file(s) from local drive or remote location
			##	(SSH) to transfer to your local host.
			##	Uncompress and unarchive files in current directory.
			##	Re-run this script to backup files.
			printf "You chose 3: Restore fom Backup"
			;;
		"q" | "Q"	)
			printf "Exiting Script"
			break
			;;
		*	)
			printf "Unknown Backup Method"
			;;
	esac
done


###
## Creating the backup archive.
#

echo -e "\nPreparing backup. This will take some time ..."
${CMDFIND} ${FILENAME} -mtime -1 -type f ! \( -path "${IGNOREFILE}" \) -prune -a -print0 | ${CMDXARGS} -0 ${CMDTAR} -rf ${ARCHIVE_BACKUP}.tar > /dev/null 2>&1


###
## Display an error message if there was a problem archiving the files.
#

#if [ $? -ne "0" ];
#then
#	err_Invocation
#fi


###
## Compressing the Archives
###

###
## Using zstd to compress the archives.
#

echo -e "\nCompressing with \"zstd\".\n"
${CMDZSTD} -z ${ARCHIVE_BACKUP}.tar > /dev/null 2>&1


###
## Display an error message if there was a problem compressing the archives.
#

##if [ ${ARCHIVE_BACKUP##*.} != "tar" ]
#if [ $? -ne "0" ]
#then
#	err_File
#fi


###
## Selection Menu To Send files
###

###
## Select Storage Location.
#

echo -e "Choose where to send files.\n"
echo -e "\t1 - Local Drive\n"
echo -e "\t2 - Remote SSH Server\n"
echo -e "\tQ - Exit Program\n\n"

read -p "-> " CHOICE

case $CHOICE in
	1)
		read -p "Enter the location for the local drive. " STORAGE
		
		#if [ ! -d "${STORAGE}" ]
		#then
		#	err_File
		#fi

		echo -e "\n\tTransfering...\n"
		${CMDCP} ${FULL_BACKUP}.tar.zst ${STORAGE} > /dev/null 2>&1

		#if [ ${FULL_BACKUP##*.} != "zst" ]
		#if [ $? -ne "0" ]
		#then
		#	err_File
		#fi

		echo -e "\nYour data has been successfuly transfered.\n\n"
		;;
	2)
		read -p "Enter the IP address of the SSH server: " SSHIPADDR
		
		if ! validIP "$SSHIPADDR"
		then
			echo -e "\033[0;31m$SSHIPADDR\033[0;0m: Invalid IP address: Make sure you entered the correct IP address."
			exit 61
		fi

		read -p "Enter the username of the remote SSH server: " SSHUSRNM

		read -p "Enter the location of the remote directory: " SSHSTORAGE
		
		echo -e "\n\tYour data is ready to be transfered.\n"
		${CMDSCP} ${FULL_BACKUP}.tar.zst scp://$SSHUSRNM@$SSHIPADDR/${SSHSTORAGE} > /dev/null 2>&1
		
		#if [ $? -ne "0" ];
		#then
		#	echo -e "Error [255]: Failed to connect to the SSH server.\n"
		#	echo -e "Make sure you are using the correct username.\n"
		#	echo -e "Check your network connection and server status.\n\n"
		#	exit 255
		#fi
		
		echo -e "\n\tSecure transfer of your data has finished.\n\n"
		;;
	'Q')
		;&
	'q')
		echo -e "\n\tExit Program\n\n"
		exit 0;
		;;
	*)
		echo -e "\n\tUnknown character entered. Exiting.\n\n"
		exit 1;
		;;
esac

exit 0
