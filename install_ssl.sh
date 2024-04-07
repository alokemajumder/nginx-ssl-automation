#!/bin/bash

# Ubuntu Security Hardening Script
# Author: Alok Majumder
# GitHub: https://github.com/alokemajumder
# License: MIT License

# DISCLAIMER:
# This script is provided "AS IS" without warranty of any kind, express or implied. The author expressly disclaims any and all warranties, 
# express or implied, including any warranties as to the usability, suitability or effectiveness of any methods or measures this script 
# attempts to apply. By using this script, you agree that the author shall not be held liable for any damages resulting from the use of this script.

# This script installs Let's Encrypt SSL for Nginx on Linux and sets up automated renewals

# Function to check if a domain resolves and display nameservers if it does not
check_domain_resolution() {
    if ! host "$1" > /dev/null; then
        echo "The domain $1 does not resolve. Please ensure the domain is correctly pointed to this server's IP address."
        echo "Current nameservers for $1:"
        dig +short NS $1
        exit 1
    else
        echo "The domain $1 resolves correctly."
    fi
}

# Detect Linux distribution and set package manager and update commands
if [ -f /etc/debian_version ]; then
    PM="apt"
    PKG_INSTALL="apt install -y"
    UPDATE_CMD="apt update && apt upgrade -y"
    ADD_REPO_CMD="add-apt-repository -y"
elif [ -f /etc/redhat-release ]; then
    PM="dnf"
    if command -v dnf > /dev/null; then
        PKG_INSTALL="dnf install -y"
    else
        PM="yum"
        PKG_INSTALL="yum install -y"
    fi
    UPDATE_CMD="$PM update -y"
    ADD_REPO_CMD="dnf config-manager --add-repo"
else
    echo "Unsupported Linux distribution. Exiting."
    exit 1
fi

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Check if Nginx is installed and running
if ! command -v nginx > /dev/null; then
    echo "Nginx is not installed. Installing Nginx..."
    $PKG_INSTALL nginx
    systemctl start nginx
    systemctl enable nginx
else
    echo "Nginx is already installed."
    nginx -v
fi

# Prompt for domain and email
read -p "Enter the domain name for the SSL certificate (e.g., example.com): " domain
read -p "Enter your email address for urgent renewal and security notices (e.g., user@example.com): " email

# Check and resolve domain before proceeding
check_domain_resolution "$domain"

# Ask if user wants to back up Nginx configurations
echo "Do you want to take a backup of existing Nginx configuration files before making changes? (yes/no)"
read backup_choice

if [[ "$backup_choice" == "yes" ]]; then
    echo "Backing up Nginx configuration files..."
    cp -r /etc/nginx /etc/nginx-backup
    echo "Backup completed and stored in /etc/nginx-backup."
elif [[ "$backup_choice" == "no" ]]; then
    echo "WARNING: Proceeding without taking a backup of existing Nginx configuration files."
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Update system packages
echo "Updating system packages..."
$UPDATE_CMD

# Install dnsutils if not installed (debian only, for Fedora it's bind-utils)
if [[ "$PM" == "apt" ]]; then
    $PKG_INSTALL software-properties-common dnsutils
elif [[ "$PM" == "dnf" || "$PM" == "yum" ]]; then
    $PKG_INSTALL bind-utils
fi

# Add the repository for certbot
echo "Adding Certbot repository..."
if [[ "$PM" == "apt" ]]; then
    $ADD_REPO_CMD ppa:certbot/certbot
    $UPDATE_CMD
    $PKG_INSTALL certbot python3-certbot-nginx
elif [[ "$PM" == "dnf" ]]; then
    $PKG_INSTALL certbot python3-certbot-nginx
elif [[ "$PM" == "yum" ]]; then
    $PKG_INSTALL epel-release
    $PKG_INSTALL certbot python3-certbot-nginx
fi

# Generate the SSL Certificate
echo "Generating SSL certificate for $domain using email $email..."
certbot --nginx -d "$domain" --redirect --agree-tos --email "$email"

# Confirm SSL installation
echo "Verifying the SSL certificate installation..."
if nginx -t && systemctl reload nginx; then
    echo "Nginx configuration is valid and has been reloaded successfully."
else
    echo "Failed to apply Nginx configuration. Please check for errors."
    exit 1
fi

# Test automatic renewal process
echo "Testing automatic renewal..."
if certbot renew --dry-run; then
    echo "Automatic renewal test passed."
else
    echo "Automatic renewal test failed. Check for errors."
    exit 1
fi

# Setup crontab for auto-renewal
(crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --renew-hook 'systemctl reload nginx'") | crontab -

# Installation and verification complete
echo "SSL certificate installation and verification complete for $domain."
echo "Auto-renewal is set up. Your SSL certificate will automatically renew and Nginx will reload after renewal."
