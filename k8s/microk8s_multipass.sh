#!/bin/bash
set -e

######################################
# Section 1: MicroK8s Setup
######################################
echo "[+] Installing MicroK8s and CLI tools..."

# Install microk8s and CLI helpers
sudo snap install microk8s --classic
sudo snap install kubectl --classic
sudo snap install kubectx --classic  # includes kubens

# Add user to group for permissions
sudo usermod -aG microk8s $USER
sudo chown -f -R $USER ~/.kube

echo "[+] Enabling essential MicroK8s addons..."
microk8s enable dns storage

# Detect active IP (works for wifi/ethernet)
ACTIVE_IP=$(hostname -I | awk '{print $1}')
echo "[+] Detected active IP: $ACTIVE_IP"

# Patch MicroK8s configs to use active IP
echo "[+] Updating MicroK8s advertise and node IP..."
sudo sed -i "s/--advertise-address=.*/--advertise-address=$ACTIVE_IP/" /var/snap/microk8s/current/args/apiserver || true
sudo sed -i "s/--node-ip=.*/--node-ip=$ACTIVE_IP/" /var/snap/microk8s/current/args/kubelet || true

# Restart services for changes
sudo systemctl restart snap.microk8s.daemon-apiserver
sudo systemctl restart snap.microk8s.daemon-kubelet

######################################
# Section 2: Multipass Workers
######################################
echo "[+] Installing Multipass..."
sudo snap install multipass --classic

echo "[+] Launching worker nodes (8GiB storage each)..."
multipass launch -n worker1 --mem 2G --disk 8G --cpus 2
multipass launch -n worker2 --mem 2G --disk 8G --cpus 2

######################################
# Section 3: Cluster Join
######################################
echo "[+] Generating join command..."
JOIN_CMD=$(microk8s add-node | grep "microk8s join" | head -n 1)

cat <<EOF

=================================================
 Manual Step: Join Workers
=================================================
Run these commands to attach workers to the cluster:

multipass exec worker1 -- sudo $JOIN_CMD
multipass exec worker2 -- sudo $JOIN_CMD

Then check nodes with:
  microk8s kubectl get nodes

To taint the control plane (prevent scheduling workloads):
  microk8s kubectl taint nodes \$(hostname) node-role.kubernetes.io/control-plane:NoSchedule

=================================================
EOF

echo "[+] Setup complete!"
