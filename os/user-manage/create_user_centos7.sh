#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "==== CentOS 7 User Creation Script ===="
echo

read -p "Enter username to create: " USERNAME

if [[ ! "$USERNAME" =~ ^[a-z][-a-z0-9_]*$ ]]; then
  echo "Error: Invalid username"
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  echo "Error: User already exists!"
  exit 1
fi

read -p "Full Name (optional): " FULLNAME

echo
echo "Creating user..."
useradd -m -c "$FULLNAME" "$USERNAME" || exit 1
passwd "$USERNAME" || exit 1

echo
read -p "Add $USERNAME to wheel group (sudo)? (y/N): " ADD_WHEEL
if [[ "$ADD_WHEEL" =~ ^[Yy]$ ]]; then
  usermod -aG wheel "$USERNAME" || echo "Warning: Failed to add to wheel group"
fi

if getent group docker > /dev/null 2>&1; then
  read -p "Add $USERNAME to docker group? (y/N): " ADD_DOCKER
  if [[ "$ADD_DOCKER" =~ ^[Yy]$ ]]; then
    usermod -aG docker "$USERNAME" || echo "Warning: Failed to add to docker group"
  fi
fi

echo
echo "Setting up SSH directory..."

USER_HOME="/home/$USERNAME"
mkdir -p "$USER_HOME/.ssh" || exit 1
touch "$USER_HOME/.ssh/authorized_keys" || exit 1
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh" || exit 1
chmod 700 "$USER_HOME/.ssh" || exit 1
chmod 600 "$USER_HOME/.ssh/authorized_keys" || exit 1

echo
echo "Opening vi to paste the public SSH key..."
echo "Press 'i' to insert, paste key, then ESC -> :wq -> ENTER"

vi "$USER_HOME/.ssh/authorized_keys"

if [ ! -s "$USER_HOME/.ssh/authorized_keys" ]; then
  echo
  echo "Warning: No SSH key was added"
fi

echo
echo "User $USERNAME created successfully!"