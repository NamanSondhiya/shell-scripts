#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "==== Linux User Creation Script ===="
echo

read -p "Enter username to create: " USERNAME

if [[ ! "$USERNAME" =~ ^[a-z][-a-z0-9_]*$ ]]; then
  echo "Error: Invalid username. Must start with lowercase letter and contain only lowercase letters, numbers, hyphens, and underscores."
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  echo "Error: User already exists!"
  exit 1
fi

read -p "Full Name (optional): " FULLNAME
read -p "Room Number (optional): " ROOM
read -p "Work Phone (optional): " WORKPHONE
read -p "Home Phone (optional): " HOMEPHONE
read -p "Other Info (optional): " OTHER

echo
echo "Creating user..."
adduser --gecos "$FULLNAME,$ROOM,$WORKPHONE,$HOMEPHONE,$OTHER" "$USERNAME" || exit 1

echo
read -p "Add $USERNAME to sudo group? (y/N): " ADD_SUDO
if [[ "$ADD_SUDO" =~ ^[Yy]$ ]]; then
  echo "Adding $USERNAME to sudo group..."
  usermod -aG sudo "$USERNAME" || echo "Warning: Failed to add to sudo group"
fi

if getent group docker > /dev/null 2>&1; then
  read -p "Add $USERNAME to docker group? (y/N): " ADD_DOCKER
  if [[ "$ADD_DOCKER" =~ ^[Yy]$ ]]; then
    echo "Adding $USERNAME to docker group..."
    usermod -aG docker "$USERNAME" || echo "Warning: Failed to add to docker group"
  fi
fi

echo
echo "Setting up SSH directory..."

USER_HOME=$(eval echo "~$USERNAME")

mkdir -p "$USER_HOME/.ssh" || exit 1
touch "$USER_HOME/.ssh/authorized_keys" || exit 1

chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh" || exit 1
chmod 700 "$USER_HOME/.ssh" || exit 1
chmod 600 "$USER_HOME/.ssh/authorized_keys" || exit 1

echo
echo "Opening nano to paste the public SSH key..."
echo "Paste the key, then press CTRL+X -> Y -> ENTER"

nano "$USER_HOME/.ssh/authorized_keys"

if [ ! -s "$USER_HOME/.ssh/authorized_keys" ]; then
  echo
  echo "Warning: No SSH key was added. User will need password authentication."
fi

echo
echo "User $USERNAME created successfully!"
echo
echo "To test SSH access, try: ssh $USERNAME@localhost"
