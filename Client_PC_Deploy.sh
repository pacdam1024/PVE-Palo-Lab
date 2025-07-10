#!/bin/bash

#================================================================
# Proxmox VM Cloning Script (Corrected)
#
# This script clones a Proxmox template multiple times, assigning
# specific names, VM IDs, network configurations, and VLANs.
#================================================================

# --- Configuration ---

# ID of the template to clone
TEMPLATE_ID=103

# The starting VM ID for the new clones.
STARTING_VMID=1002

# The total number of VMs to create.
NUM_VMS=19

# The target Proxmox node where the new VMs will be created.
TARGET_NODE="139PVE4"

# The MAC address for the network interface of each new VM.
MAC_ADDRESS="00:0C:29:0F:42:6E"

# The Proxmox bridge to connect the new VMs to.
BRIDGE="vmbr10"

# An array of VLANs to be assigned to each student VM.
# This list corresponds to students 2 through 20.
VLANS=(
    1392 1393 1394 1395 1396 1397 1398 1399 1400 1401
    1402 1403 1404 1405 1406 1407 1408 1409 1410
)

# --- Script Execution ---

echo "Starting the VM cloning process..."

# We start the loop from 2 because "Client-Student(1)" with VMID 1001 already exists.
for i in $(seq 2 20); do
    # Calculate the current VM ID for the new clone.
    current_vmid=$((STARTING_VMID + i - 2))

    # Get the corresponding VLAN for the current student.
    current_vlan_index=$((i - 2))
    current_vlan=${VLANS[$current_vlan_index]}

    # Define the name for the new VM using a valid DNS-compliant format.
    new_name="Client-Student-$i" # <-- CORRECTED LINE

    echo "--------------------------------------------------"
    echo "Creating: ${new_name}"
    echo "VMID:     ${current_vmid}"
    echo "VLAN:     ${current_vlan}"
    echo "--------------------------------------------------"

    # Clone the template to a new VM.
    qm clone $TEMPLATE_ID $current_vmid --name "$new_name" --target "$TARGET_NODE" --storage local-lvm

    if [ $? -eq 0 ]; then
        echo "VM cloned successfully."

        # Configure the network adapter with the specified MAC address and VLAN.
        qm set $current_vmid --net0 virtio=${MAC_ADDRESS},bridge=${BRIDGE},tag=${current_vlan}

        if [ $? -eq 0 ]; then
            echo "Network configuration applied successfully."
        else
            echo "Error: Failed to configure the network for ${new_name}."
        fi
    else
        echo "Error: Failed to clone the template for ${new_name}."
    fi
    echo ""
done

echo "=================================================="
echo "All cloning and configuration tasks are complete."
echo "=================================================="