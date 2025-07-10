#!/bin/bash

# ==============================================================================
# Proxmox Tagged VLAN Interface Creation Script (v2)
#
# This script creates tagged VLAN interfaces using the 'vlan-raw-device'
# syntax, matching the user-provided example. It directly modifies the
# /etc/network/interfaces file.
#
# It is idempotent, meaning it will not create duplicate entries if an
# interface for a specific VLAN already exists.
# ==============================================================================

# --- Configuration ---
VLAN_START=1391
VLAN_END=1412
RAW_DEVICE="vmbr10" # The parent bridge for the VLAN tags
INTERFACES_FILE="/etc/network/interfaces"

# --- Pre-run Checks ---
# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use 'sudo'."
   exit 1
fi

# Check if the network interfaces file exists
if [ ! -f "$INTERFACES_FILE" ]; then
    echo "ERROR: Network configuration file not found at $INTERFACES_FILE"
    exit 1
fi

# Check if the raw device exists in the configuration
if ! grep -q "iface ${RAW_DEVICE}" "$INTERFACES_FILE"; then
    echo "ERROR: Raw device '${RAW_DEVICE}' not found in $INTERFACES_FILE."
    echo "Please ensure the parent bridge is configured first."
    exit 1
fi

echo "Starting tagged VLAN interface creation on '${RAW_DEVICE}' from VLAN $VLAN_START to $VLAN_END..."

# --- Main Loop ---
# Loop through each VLAN ID in the specified range
for vlan_id in $(seq $VLAN_START $VLAN_END); do
    interface_name="vlan${vlan_id}"

    # Check if the interface already exists in the configuration file
    if grep -q "iface ${interface_name}" "$INTERFACES_FILE"; then
        echo "Interface '${interface_name}' already exists. Skipping."
    else
        echo "Creating configuration for interface '${interface_name}'."

        # Append the new interface configuration to the interfaces file,
        # matching the provided working example.
        cat << EOF >> "$INTERFACES_FILE"

auto ${interface_name}
iface ${interface_name} inet static
	vlan-raw-device ${RAW_DEVICE}
EOF
    fi
done

echo ""
echo "--- Script Finished ---"
echo "All VLAN interface configurations have been added to $INTERFACES_FILE."
echo ""
echo "IMPORTANT: To apply the new network configuration, run the following command:"
echo "  ifreload -a"
echo ""
