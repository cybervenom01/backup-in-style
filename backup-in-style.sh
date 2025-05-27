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

E_NOTFOUND=1
E_UNKCOMMAND=2
E_INVSTAT=123


###
## Function to catch an error.
#

function catch_Error()
{

}


###
## Function to display failure.
#

function err_Failure()
{

}


###
## Function which display an error message if the IP address was entered incorrectly.
#

function validIP()
{

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
## Choos a file or directory to ignore.
#


echo -e "\nYou can leave this empty if you don't want to ignore any files or directories.\n"
read -p "Choose which file or directory to ignore: " IGNOREFILE


###
## Input validation
#

if [ ! -e "${FILENAME}" ];
then
	echo "${FILENAME}: No such file or directory."
	exit $E_NOTFOUND;
fi


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
	echo -e "Invocation of the commands exited with status 1 - 125.\n\n"
	exit $E_INVSTAT;
fi


###
## Compressing the Archives
###

###
## Using zstd to compress the archives.
#

echo -e "\nCompressing with \"zstd\".\n"
$CMDZSTD -z $FULL_BACKUP.tar > /dev/null 2>&1


###
## Display an error message if there was a problem compressing the archives.
#

if [ ${FULL_BACKUP##*.} != "tar" ];
then
	echo "Not a \"tar\" archive.\n\n"
	exit $E_NOTFOUND;
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
		
		echo -e "\n\tTransfering...\n"
		$CMDCP $FULL_BACKUP.tar.zst $STORAGE > /dev/null 2>&1

		if [ ${FULL_BACKUP##*.} != "zst" ];
		then
			echo -e "\nNot a \"zst\" compressed archive.\n\n"
			exit $E_NOTFOUND;
		fi
		
		echo -e "\nYour data has been successfuly transfered.\n\n"
		;;
	2)
		read -p "Enter the IP address of the SSH server: " SSHIPADDR
		##NOTE: Input validation. Enter the correct IPv4 address in
		#	the input prompt. If the IP address is written wrong,
		#	display an error message.
		read -p "Enter the username of the remote SSH server: " SSHUSRNM

		read -p "Enter the location of the remote directory: " SSHSTORAGE
		
		echo -e "\n\tYour data is ready to be transfered.\n"
		$CMDSCP $FULL_BACKUP.tar.zst $SSHUSRNM@$SSHIPADDR:$SSHSTORAGE > /dev/null 2>&1

		if [ $? -ne "0" ];
		then
			echo -e "\nAn error has occurred. Make sure the IP address corresponds to the SSH server"
			echo -e "you are trying to communicate with. Also check if the username is not misspelled,"
			echo -e " and the username exists in the corresponding SSH server.\n\n"
			exit 1;
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
