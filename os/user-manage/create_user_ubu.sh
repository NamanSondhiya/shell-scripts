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

USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)

if [ -z "$USER_HOME" ] || [ ! -d "$USER_HOME" ]; then
  echo "Error: Could not determine home directory for $USERNAME"
  exit 1
fi

mkdir -p "$USER_HOME/.ssh" || exit 1
touch "$USER_HOME/.ssh/authorized_keys" || exit 1

chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh" || exit 1
chmod 700 "$USER_HOME/.ssh" || exit 1
chmod 600 "$USER_HOME/.ssh/authorized_keys" || exit 1

# Check sshd supports pubkey auth
SSHD_CONFIG="/etc/ssh/sshd_config"
PUBKEY_AUTH=$(grep -i "^PubkeyAuthentication" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
if [[ "$PUBKEY_AUTH" == "no" ]]; then
  echo "Warning: PubkeyAuthentication is set to 'no' in $SSHD_CONFIG — SSH key login will NOT work until you change it to 'yes' and restart sshd."
fi

AUTH_KEYS_FILE=$(grep -i "^AuthorizedKeysFile" "$SSHD_CONFIG" 2>/dev/null | awk '{print $2}')
if [ -n "$AUTH_KEYS_FILE" ] && [[ "$AUTH_KEYS_FILE" != ".ssh/authorized_keys"* ]] && [[ "$AUTH_KEYS_FILE" != "%h/.ssh/authorized_keys"* ]]; then
  echo "Warning: sshd AuthorizedKeysFile is set to '$AUTH_KEYS_FILE' — not the default. Verify this script writes to the correct path."
fi

echo
echo "Opening nano to paste the public SSH key..."
echo "Paste the key, then press CTRL+X -> Y -> ENTER"
echo

while true; do
  nano "$USER_HOME/.ssh/authorized_keys"

  if [ ! -s "$USER_HOME/.ssh/authorized_keys" ]; then
    read -p "No key saved. Retry? (y/N): " RETRY
    [[ "$RETRY" =~ ^[Yy]$ ]] && continue
    echo "Warning: No SSH key added. User will need password authentication."
    break
  fi

  # Validate key format
  INVALID_LINES=$(grep -v -E '^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|sk-ssh-ed25519|sk-ecdsa-sha2-nistp256)[[:space:]]' \
    "$USER_HOME/.ssh/authorized_keys" | grep -v '^\s*$' | grep -v '^#')

  if [ -n "$INVALID_LINES" ]; then
    echo "Warning: Some lines do not look like valid SSH public keys:"
    echo "$INVALID_LINES"
    read -p "Edit again? (y/N): " RETRY
    [[ "$RETRY" =~ ^[Yy]$ ]] && continue
  fi

  KEY_COUNT=$(grep -cE '^(ssh-|ecdsa-|sk-)' "$USER_HOME/.ssh/authorized_keys" || true)
  echo "SSH keys added: $KEY_COUNT"
  break
done

# Re-enforce permissions in case nano changed them
chown "$USERNAME:$USERNAME" "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"

echo
echo "User $USERNAME created successfully!"
echo
echo "To test SSH access, try: ssh $USERNAME@$(hostname -I | awk '{print $1}')"
