#!/bin/bash

# Move connection file to /data/, so it can be more easily picked up in Host
cp /root/static_eth0.nmconnection /data/

# Bring up the connection
nmcli con up static_eth0

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

