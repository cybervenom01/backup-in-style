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
CMDRSYNC=/usr/bin/rsync


###
## Location to log file
#

LOGFILE="backup.log"
LOGDIR=".backupstyle.d"

if [ ! -d "$LOGDIR" ]
then
	mkdir ${HOME}/$LOGDIR
	chmod 755 ${HOME}/$LOGDIR
else
	printf "${HOME}/$LOGDIR already exists.\n"
fi

if [ ! -a ${HOME}/$LOGDIR/$LOGFILE ]
then
	touch ${HOME}/$LOGDIR/$LOGFILE
	chmod 644 ${HOME}/$LOGDIR/$LOGFILE
else
	printf "${HOME}/$LOGDIR/$LOGFILE already exists.\n"
fi


###
## Assigning Names for the Backup Files
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
	E_STAT=$1
	LINE_NO=$2
	E_MSG="$( date +%c ): $( uname -n ): ERROR: [$E_STAT] occurred on line $LINE_NO\n"

	printf "%b" "$E_MSG" | tee >> "${HOME}/$LOGDIR/$LOGFILE"
	exit $E_STAT
}


###
## Log Successful Messages Function
#

successMessage ()
{
	S_MSG="$( date +%c ): $( uname -n ): SUCCESS: Data transfer successful.\n"

	printf "%b" "$S_MSG" | tee >> "${HOME}/$LOGDIR/$LOGFILE"
}


###
## Function which display an error message if the IP address was entered incorrectly.
##TODO: Rewrite this function.

invalidIP()
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
## Call Function to display ascii art.
#

clear

asciiArt

echo
echo


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
	PS3='Choose a Backup Method: '
	CHOICES=("Full" "Incremental" "Restore" "Quit")
	
	select OPT in "${CHOICES[@]}"
	do
		case $OPT in 
			"Full" )
				## Secondary Menu.
				PS3='Select the location to transfer your archives: '
				SELECTION=("SSH" "Local" "Go Back" "Quit")

				select CHOICE in "${SELECTION[@]}"
				do
					case $CHOICE in
						"SSH" )
							##NOTE: For some reason the errors are not being detected in
							##	this section of the code
							printf "Enter the destination directory for the ssh server: "

							read -p "-> " SSHSTORAGE

							printf "Enter the IP address of the ssh server: "
							##TODO: Detect error in how the IP address is written.
							read -p "-> " SSHIPADDR
							
							printf "Enter the username of the ssh server: "

							read -p "-> " SSHUSRNAME

							printf "Choose the files to backup: "

							read -p "-> " DIRNAME

							printf "The files will be compressed while thay are being transfered.\n"

							printf "This will take some time . . .\n"

							$CMDRSYNC} -aiz --zc=zstd --zl=11 --progress ${DIRNAME}/* $SSHUSRNAME@SSHIPADDR:$SSHSTORAGE

							printf "Finished compressing files.\n"

							successMessage
							break 1
							;;
						"Local" )
							printf "Enter the destination to the local directory: "

							read -p "-> " LOCALDIR

							printf "Choose the files to backup: "

							read -p "-> " DIRNAME

							printf "The files will be compressed while they are being transfered.\n"

							printf "This will take some time . . .\n"

							${CMDRSYNC} -aiz --zc=zstd --zl=11 --progress ${DIRNAME}/* ${LOCALDIR}
							
							successMessage
							break 1
							;;
						"Go Back" )
							break 2
							;;
						"Quit" )
							printf "Exiting the script.\n\n"
							exit 1
							;;
						* )
							printf "Option not found in the menu.\n"
							;;
					esac
				done
				;;
			"Incremental" )
				PS3='Select the location to transfer your archives: '
                                SELECTION=("SSH" "Local" "Go Back" "Quit")

				select CHOICE in "${SELECTION[@]}"
				do
					case $CHOICE in
						"SSH" )
							printf "Enter the destination directory for the ssh server: "

                                                        read -p "-> " SSHSTORAGE

                                                        printf "Enter the IP address of the ssh server: "
                                                        ##TODO: Detect error in how the IP address is written.
                                                        read -p "-> " SSHIPADDR

                                                        printf "Enter the username of the ssh server: "

                                                        read -p "-> " SSHUSRNAME

                                                        printf "Choose the files to backup: "

                                                        read -p "-> " DIRNAME

                                                        printf "The files will be compressed while thay are being transfered.\n"

                                                        printf "This will take some time . . .\n"

                                                        ${CMDRSYNC} -aiz --zc=zstd --zl=11 --update --progress ${DIRNAME}/* $SSHUSRNAME@$SSHIPADDR:${SSHSTORAGE}
							successMessage

							break 1
							;;
						"Local" )
							printf "Enter the destination to the local directory: "

                                                        read -p "-> " LOCALDIR

                                                        printf "Choose the files to backup: "

                                                        read -p "-> " DIRNAME

                                                        printf "The files will be compressed while they are being transfered.\n"

                                                        printf "This will take some time . . .\n"

                                                        ${CMDRSYNC} -aiz --zc=zstd --zl=11 --progress --update ${DIRNAME}/* ${LOCALDIR}

							successMessage

							break 1
							;;
						"Go Back" )
							printf "You selected to go back to the main menu.\n"
							break 2
							;;
						"Quit" )
							printf "Exiting the script.\n\n"
							exit 1
							;;
						* )
							printf "Option not found in the menu.\n"
							;;
					esac
				done
				;;
			"Restore" )
				PS3="Select the location you want to restore from: "
				PICK=("SSH" "Local" "Go Back" "Quit")

				select OPTION in "${PICK[@]}"
				do
					case $OPTION in
						"SSH" )
							printf "Enter the remote location of the backup files to restore: "

							read -p "-> " SSHSTORAGE

							printf "Enter the IP address of the ssh server: "

							read -p "-> " SSHIPADDR

							printf "Enter the username of the ssh server: "

							read -p "-> " SSHUSRNAME

							printf "Enter the local directory name to transfer the backup files to: "

							read -p "-> " DIRNAME

							printf "Files are being transfered.\n"

							printf "This will take some time . . .\n"

							${CMDRSYNC} -aiz --zc=zstd --zl=11 --progress $SSHUSRNAME@$SSHIPADDR:${SSHSTORAGE}/* ${DIRNAME}

							successMessage

							break 1
							;;
						"Local" )
							printf "Enter the local directory name of the backup files to restore: "

							read -p "-> " LOCALDIR

							printf "Enter the directory name to transfer the backup files to: "

							read -p "-> " DIRNAME

							printf "Files are being transfered.\n"

							printf "This will take some time . . .\n"

							${CMDRSYNC} -aiz --zc=zstd --zl=11 --progress ${LOCALDIR}/* ${DIRNAME}

							successMessage

							break 1
							;;
						"Go Back" )
							printf "Go back to the main menu.\n"
							break 2
							;;
						"Quit" )
							printf "Exiting the script.\n\n"
							exit 1
							;;
						* )
							printf "Option not found in the menu.\n"
							;;
					esac
				done
				;;
			"Quit" )
				echo "Exiting the script.\n\n"
				exit 1
				;;
			* )
				echo "Option not found in the menu.\n"
				;;
		esac
	done
done

exit 0
