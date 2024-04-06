## nginx-ssl-automation

This repository contains a script for automating the installation and renewal of Let's Encrypt SSL certificates on Linux servers using Nginx. It simplifies the setup of SSL on Nginx by handling all necessary installations, configurations, and renewals automatically.

## Features

- **Automated SSL Certificate Installation**: Sets up SSL certificates from Let's Encrypt for your domain hosted on Nginx.
- **Domain Resolution Check**: Ensures your domain resolves correctly before installation to prevent errors.
- **Backup Option**: Offers an option to backup existing Nginx configurations before making changes.
- **Automated Renewals**: Configures cron jobs to handle certificate renewals automatically.
- **Cross-Distro Support**: Supports both Debian and Fedora-based Linux distributions.

## Prerequisites

Before running this script, ensure the following:
- You are using a Linux server running either a Debian-based (like Ubuntu or Debian itself) or Fedora-based (like Fedora or CentOS) distribution.
- You have root or sudo privileges on the server.
- Nginx is installed and running.
- DNS utilities are available (`dnsutils` for Debian-based systems or `bind-utils` for Fedora-based systems).

## Installation

To set up the SSL automation script, follow these steps:


## Clone the repository

## Change to the directory

`cd nginx-ssl-automation`

## Make the script executable

`chmod +x install_ssl.sh`

## Run the script with root privileges

`sudo ./install_ssl.sh`

## Usage

Running the script will prompt you for several inputs:

-   **Domain Name**: The fully qualified domain name (FQDN) for which you want to install the SSL certificate.
-   **Email Address**: Contact email address for urgent renewal and security notices from Let's Encrypt.
-   **Backup**: Whether to backup existing Nginx configuration files before making changes.

Follow the interactive prompts to complete the installation and configuration of your SSL certificate.

## Contributing

Contributions to enhance this script are welcome! Please fork the repository and submit pull requests with your proposed changes.

## License

This project is released under the MIT License.

## Support

For support, feature requests, or bug reporting, please open an issue. 

## Disclaimer

This script is provided "as is", without warranty of any kind. Use it at your own risk. Always backup your data before making system changes.
