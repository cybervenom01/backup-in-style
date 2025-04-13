# Backup In Style

![License](https://img.shields.io/badge/license-MIT-blue)
![Bash](https://img.shields.io/badge/language-Bash-lightgrey)

## Description

Data loss can occur unexpectedly due to various factors such as accidental deletion,
data corruption, power outages, malware infections, or inadvertent user actions.
Implementing regular backup procedures is crucial to safeguard important information.

"Backup In Style" is an interactive Bash script designed to facilitate the secure
backup of user-specified data. Upon execution, the script prompts the user for necessary
input, providing clear and user-friendly instructions to guide the process. It then
compresses the selected files or directories into a .tar.gz archive, ensuring efficient
storage and integrity of the backed-up data.

The script's codebase includes comprehensive comments to enhance readability and
understanding, making it accessible for users who wish to review or modify its
functionality.

By utilizing "Backup in Style", users can establish a reliable and streamlined approach
to data preservation, mitigating the risks associated with data loss incidents.


## Features

- Interactive and user-friendly
- Supports file and directory selection
- Creates compressed `.tar.gz` archives
- Commented for ease of customization


## Installation

`git clone https://github.com/cybervenom01/backup-in-style.git`

`cd backup-in-style`

`chmod +x backup.sh`


## Usage

`./backup.sh`

``` Bash
Welcome to Backup in Style!

Enter the directory or file you want to backup: /home/user/directory

Enter a name for the backup: docs_backup

Creating archive...

Backup complete: docs_backup.tar.gz
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
