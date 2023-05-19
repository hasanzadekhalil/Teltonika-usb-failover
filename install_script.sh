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
mwan3=/etc/config/mwan3.bak
if test -f "$mwan3"; then
	echo "Failover backup exist"
else
	echo "Creating Failover backup..."
	cp /etc/config/mwan3 /etc/config/mwan3.bak
fi
if grep -R "config interface 'wanusb'" /etc/config/mwan3; then
	echo "Failover Configuration exist!"
else
	echo "Installing Failover Configuration"
cat <<EOT>> /etc/config/mwan3
config interface 'wanusb'
	option enabled '1'
	option interval '3'
	option family 'ipv4'
	
config condition
	option interface 'wanusb'
	option track_method 'ping'
	option reliability '1'
	option count '1'
	option timeout '2'
	option down '3'
	option up '3'
	list track_ip '1.1.1.1'
	list track_ip '8.8.8.8'
	
config member 'wanusb_member_mwan'
	option interface 'wanusb'
	option metric '1'
	
config member 'wanusb_member_balance'
	option interface 'wanusb'
	option weight '1'
EOT
fi
echo "Adding UsbWan to Failover Configuration"
mwan='/etc/config/mwan3'
config1="list use_member 'wan_member_mwan'"
config1correct="list use_member 'wanusb_member_mwan'"
sed -i "s/$config1/$config1correct/g" "$mwan"
config2="list use_member 'wan_member_balance'"
config2correct="list use_member 'wanusb_member_balance'"
sed -i "s/$config2/$config2correct/g" "$mwan"
config3="config interface 'mob1s1a1'
	option interval '3'
	option enabled '0'
	option family 'ipv4'
"
config3correct="config interface 'mob1s1a1'
	option interval '3'
	option family 'ipv4'
	option enabled '1'"
sed -i "s/$config3/$config3correct/g" "$mwan"    
echo "Rebooting Router..."
reboot
