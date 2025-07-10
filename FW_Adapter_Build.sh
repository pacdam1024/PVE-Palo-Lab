#!/bin/bash

# --- Configuration ---
BRIDGE="vmbr10"
START_VMID=1391
END_VMID=1412

# --- Static MAC Addresses (WARNING: Causes conflicts if used on multiple running VMs) ---
MAC0="00:50:56:8a:7c:78"
MAC1="00:50:56:8a:91:be"
MAC2="00:50:56:8a:91:c4"
MAC3="00:50:56:8a:54:c7"
MAC4="00:50:56:8a:84:17"
MAC5="00:50:56:8a:b3:fc"

# --- Logic ---
echo "--- Starting network configuration for VMs $START_VMID to $END_VMID ---"

# Loop through each VM ID in the specified range
for vmid in $(seq $START_VMID $END_VMID); do
  
  # Calculate the VLAN for each network interface based on the VMID
  vlan0=$vmid
  vlan1=$((vmid + 22))
  vlan2=$vmid  # Same as net0
  vlan3=$((vmid + 44))
  vlan4=$((vmid + 66))
  vlan5=$((vmid + 88))

  # Apply the settings to the VM, including the static MAC address.
  echo "Configuring VM $vmid..."
  qm set $vmid --net0 virtio,bridge=$BRIDGE,tag=$vlan0,macaddr=$MAC0
  qm set $vmid --net1 virtio,bridge=$BRIDGE,tag=$vlan1,macaddr=$MAC1
  qm set $vmid --net2 virtio,bridge=$BRIDGE,tag=$vlan2,macaddr=$MAC2
  qm set $vmid --net3 virtio,bridge=$BRIDGE,tag=$vlan3,macaddr=$MAC3
  qm set $vmid --net4 virtio,bridge=$BRIDGE,tag=$vlan4,macaddr=$MAC4
  qm set $vmid --net5 virtio,bridge=$BRIDGE,tag=$vlan5,macaddr=$MAC5

done

echo "--- Configuration complete. ---"
