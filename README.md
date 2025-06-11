# Backup In Style

![Backup In Style Logo](./Images/backup-in-style-logo-0004.svg)


![Bash](https://img.shields.io/badge/language-Bash-lightgrey)
![GitHub License](https://img.shields.io/github/license/cybervenom01/backup-in-style?style=social)

## Description

Backup In Style is a lightweight, modular Bash script built for efficient
and secure file backups on Linux and Unix-like systems. It's designed
for technical users and small businesses that need a no-nonsense solution
to automate routine backups while maintaining full control over the processes.

Whether you're managing personal systems or business infrastructure, Backup In
Style offer a dependable foundation with room to grow - built with clarity,
security, and extensibility in mind.


## Features

- Interactive and user-friendly
- Secure remote transfers via SSH
- Creates compressed `.tar.zst` archives
- Clean, readable code for easy customization


## Upcoming Features

- Color-coded terminal output for enhanced status visibility and error handling
- Cron integration for scheduled, automated backups
- Detailed logging for audits and troubleshooting


## Installation

`git clone https://github.com/cybervenom01/backup-in-style.git`

`cd backup-in-style`

`chmod u+x backup-in-style.sh`


## Usage

`./backup-in-style.sh`

``` Bash
>>> $ =============== $ <<<
>>> { Backup In Style } <<<
>>> $ =============== $ <<<



Enter the directory or file you want to backup: /home/user/directory

You can leave this empty if you don't want to ignore any files.
Enter the name of the file or directory to ignore: /file/to/ignore

Creating archive...

Backup complete: docs_backup.tar.zst
```

## License

This project is licensed under the GNU General Public License - see the [LICENSE](LICENSE) file for details.
