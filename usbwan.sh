#!/bin/sh
cp /etc/config/mwan3 /etc/config/mwan3.bak
cat <<EOT>> /etc/config/mwan3
config interface 'wanusb'
	option enabled '0'
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
	option metric '4'
	
config member 'wanusb_member_balance'
	option interface 'wanusb'
	option weight '1'
EOT
