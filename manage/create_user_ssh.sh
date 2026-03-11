#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "==== Linux User Creation Script ===="
echo

read -p "Enter username to create: " USERNAME

if id "$USERNAME" &>/dev/null; then
  echo "User already exists!"
  exit 1
fi

read -p "Full Name (optional): " FULLNAME
read -p "Room Number (optional): " ROOM
read -p "Work Phone (optional): " WORKPHONE
read -p "Home Phone (optional): " HOMEPHONE
read -p "Other Info (optional): " OTHER

echo
echo "Creating user..."
adduser --gecos "$FULLNAME,$ROOM,$WORKPHONE,$HOMEPHONE,$OTHER" "$USERNAME"

echo
echo "Set password for $USERNAME"
passwd "$USERNAME"

echo
echo "Adding $USERNAME to sudo group..."
usermod -aG sudo "$USERNAME"

if getent group docker > /dev/null 2>&1; then
  echo "Adding $USERNAME to docker group..."
  usermod -aG docker "$USERNAME"
else
  echo "Docker group not found. Skipping docker group assignment."
fi

echo
echo "Setting up SSH directory..."

USER_HOME=$(eval echo "~$USERNAME")

mkdir -p "$USER_HOME/.ssh"
touch "$USER_HOME/.ssh/authorized_keys"

chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
chmod 600 "$USER_HOME/.ssh/authorized_keys"

echo
echo "Opening nano to paste the public SSH key..."
echo "Paste the key, then press CTRL+X -> Y -> ENTER"
sleep 2

nano "$USER_HOME/.ssh/authorized_keys"

echo
echo "User $USERNAME created successfully!"
echo "Added to sudo and docker groups."
echo "SSH key added."
echo

echo "Switching to user for verification..."
su - "$USERNAME"
