#!/bin/sh
echo "Package Update Process Starting..."
opkg update
cd /tmp
wget https://raw.githubusercontent.com/hasanzadekhalil/Teltonika-usb-failover/main/bondix-sane-vuci_202304061239-b0ccc80a.ipk
echo "Installing Bondix..."
opkg install bondix-sane-vuci_202304061239-b0ccc80a.ipk
opkg install usb-modeswitch
network=/etc/config/network.bak
if test -f "$network"; then
	echo "Network backup exist"
else
	echo "creating network backup..."
	cp /etc/config/network /etc/config/network.bak
fi
cp /etc/config/network /etc/config/network.bak
if grep -R "config interface 'wanusb'" /etc/config/network; then
	echo "WanUSB interface Configuration exist!"
else
	echo "Installing WanUSB Interface..."
cat <<EOT>> /etc/config/network
config interface 'wanusb'
	option metric '3'
	option device 'eth2'
	option proto 'dhcp'
EOT
fi
if grep -R "config interface 'wanusb'" /etc/config/mwan3; then
	echo "Failover Configuration exist!"
else
	echo "Installing Failover Configuration"
  mwan3=/etc/config/mwan3.bak
fi
if test -f "$mwan3"; then
	echo "Failover backup exist"
else
	echo "Creating Failover backup..."
	mv /etc/config/mwan3 /etc/config/mwan3.bak
  wget https://raw.githubusercontent.com/hasanzadekhalil/Teltonika-usb-failover/main/mwan3
  cp mwan3 /etc/config
fi
echo "Rebooting Router..."
reboot
