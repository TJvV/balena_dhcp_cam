#!/bin/bash


CON_NAME=static_eth0


# Test if connection exists

x="$(nmcli con show ${CON_NAME})"
if [ $? -eq 0 ]; then
    echo "Connection exists"
else
    echo "Adding connection"

    nmcli con add connection.id ${CON_NAME} ifname eth0 type ethernet ipv4.method manual ipv6.method disabled ipv4.addresses 192.168.10.1/24 ipv4.never-default true
fi

# Bring up the connection
nmcli con up ${CON_NAME}

# Update DHCP config
UDHCPD_CONF=/tmp/udhcpd.conf

cp "${app_udhcpd_config}" "${UDHCPD_CONF}"
if [[ -n "${app_camera_mac}" && -n "${app_camera_ip}" ]]; then
    # mac set, assign static lease
    echo "static_lease ${app_camera_mac} ${app_camera_ip}" >> "${UDHCPD_CONF}"
fi

# Start DHCP server
udhcpd "${UDHCPD_CONF}"

while true;
do
    # Ask udhcpd to update leases file
    kill -USR1 $(pidof udhcpd)
    
    # Print leases
    dumpleases


    if [ -n "${app_camera_ip}" ]; then
        ping -q "${app_camera_ip}"
    fi

    sleep 30
done

