#!/usr/bin/bash
##

###
## Commands for the script to function.
###

###
## Searches for the commands which help to compress, archive, and remotely transfer your data.
#

LST_CMDS=( "tar" "zstd" "ssh" "scp" )

for cmds in "${LST_CMDS[@]}";
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

CMDFIND=/usr/bin/find
CMDXARGS=/usr/bin/xargs
CMDTAR=/usr/bin/tar
CMDSCP=/usr/bin/scp
CMDZSTD=/usr/bin/zstd
CMDCP=/usr/bin/cp
CMDSSH=/usr/bin/ssh


###
## Assigning Names for the Backup Files
#

USR=$( whoami )
HOST=$( uname -n )
TIMESTAMP=$(date +%d%m%Y-%H%M%S)
ARCHIVE_BACKUP=${USR}-${HOST}-${TIMESTAMP}-backup
FULL_BACKUP=${1:-$ARCHIVE_BACKUP}


###
## Catch and Display Error Messages.
###

###
## Assign Error Codes To The Variables.
#

#E_STAT=1
E_NOTFOUND=2
E_INVSTAT=123


###
## Function error on file.
#

function err_File()
{
	echo -e "Error [$E_NOTFOUND]: No such file or directory.\n\n"
	exit $E_NOTFOUND
}


###
## Function error invocation of commands.
#

function err_Invocation()
{
	echo -e "Error [$E_INVSTAT]: Invocation of the commands exited with status 1 - 125\n\n"
	exit $E_INVSTAT
}


###
## Function which display an error message if the IP address was entered incorrectly.
#

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
## Display the name of the script.
#

echo -e "\n"
echo -e "\t>>>  $       $       $  <<<"
echo -e "\t>>> { Backup In Style } <<<"
echo -e "\t>>>  $       $       $  <<<"
echo -e "\n\n"


###
## Choose a file or directory to archive and compress.
###

###
## Choose a file or directory to archive.
#

read -p "Choose which file or directory to archive: " FILENAME


###
## Input Validation
#

if [ ! -e "${FILENAME}" ]
then
	err_File
fi


###
## Choos a file or directory to ignore.
#


echo -e "\nYou can leave this empty if you don't want to ignore any files or directories.\n"
read -p "Choose which file or directory to ignore: " IGNOREFILE


###
## Creating the backup archive.
#

echo -e "\nPreparing backup. This will take some time ..."
$CMDFIND ${FILENAME} -mtime -1 -type f -path ${IGNOREFILE} -prune -o -print0 | $CMDXARGS -0 $CMDTAR -rf ${FULL_BACKUP}.tar ${FILENAME} > /dev/null 2>&1


###
## Display an error message if there was a problem archiving the files.
#

if [ $? -ne "0" ];
then
	err_Invocation
fi


###
## Compressing the Archives
###

###
## Using zstd to compress the archives.
#

echo -e "\nCompressing with \"zstd\".\n"
$CMDZSTD -z ${FULL_BACKUP} > /dev/null 2>&1


###
## Display an error message if there was a problem compressing the archives.
#
##NOTE: For some reason, this variable name doesn't show the '.tar' extension.
##	It executes and displays the error message. It does what it's supposed
##	to do but why? Maybe I have to go back to where the use of 'tar' is being
##	executed. Or it has to do something with the way the variables and values
##	are being used.
if [ "${FULL_BACKUP##*.}" != "tar" ];
then
	err_File
fi


###
## Selection Menu To Send files
###

###
## Select Storage Location.
##FIXME: Create the necessary error messages for the following statements.

echo -e "Choose where to send files.\n"
echo -e "\t1 - Local Drive\n"
echo -e "\t2 - Remote SSH Server\n"
echo -e "\tQ - Exit Program\n\n"

read -p "-> " CHOICE

case $CHOICE in
	1)
		read -p "Enter the location for the local drive. " STORAGE
		if [ ! -d "${STORAGE}" ]
		then
			err_File
		fi

		echo -e "\n\tTransfering...\n"
		$CMDCP $FULL_BACKUP.tar.zst $STORAGE > /dev/null 2>&1

		if [ ${FULL_BACKUP##*.} != "zst" ]
		then
			err_File
		fi

		echo -e "\nYour data has been successfuly transfered.\n\n"
		;;
	2)
		read -p "Enter the IP address of the SSH server: " SSHIPADDR
		
		if [ ! validIP "$SSHIPADDR" ]
		then
			echo -e "$SSHIPADDR: Invalid IP address: Make sure you entered the correct IP address."
		fi

		read -p "Enter the username of the remote SSH server: " SSHUSRNM

		read -p "Enter the location of the remote directory: " SSHSTORAGE
		
		echo -e "\n\tYour data is ready to be transfered.\n"
		$CMDSCP $FULL_BACKUP.tar.zst iscp://$SSHUSRNM@$SSHIPADDR/$SSHSTORAGE > /dev/null 2>&1

		if [ $? -ne "0" ];
		then
			echo -e "Error [$?]: Failed to connect to the SSH server.\n"
			echo -e "Suggestions: Make sure you are using the correct username.\n"
			echo -e "\tCheck your network connection and sever status.\n\n"
			exit 255
		fi
		
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
