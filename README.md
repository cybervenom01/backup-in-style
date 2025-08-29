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
- Detailed logging for audits and troubleshooting
- Clean, readable code for easy customization


## Installation

Download from GitHub.

`git clone https://github.com/cybervenom01/backup-in-style.git`

`cd backup-in-style/config.d`


Make sure you run 'configure' with root privileges.

This will check for the necessary commands to run the backup
script. It will also prepare all the directories and files
for logging audits.

`# ./configure`


## Usage

`cbv@localhost: $ backupstyle`

```Bash
1) Full Backup
2) Incremental Backup
3) Restore
4) Quit
```

## License

This project is licensed under the GNU General Public License - see the [LICENSE](LICENSE) file for details.
