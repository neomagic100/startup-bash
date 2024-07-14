#!/bin/bash

enableSSH () {
	LOGIN_PERMITTED=$(egrep ^"PermitRootLogin yes" < /etc/ssh/sshd_config)
	
	if [[ $LOGIN_PERMITTED == "" ]]; then
		echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
		systemctl restart sshd
	fi

	systemctl enable ssh 2>&1 3>&1 1>log.txt 2>/dev/null
	echo "Enabled SSH" >> log.txt
}

editConf () {
	if ! [ -f /etc/sysctl.d/99-sysctl.conf ]; then
		touch /etc/sysctl.d/99-sysctl.conf
	fi

	IPV4=$(egrep ^net.ipv4.ip_forward < /etc/sysctl.d/99-sysctl.conf)
	IPV6=$(egrep ^net.ipv6.conf.all.forwarding < /etc/sysctl.d/99-sysctl.conf)

	if [[ $IPV4 == "" ]]; then
		echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-sysctl.conf
	fi

	if [[ $IPV6 == "" ]]; then
		echo "net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.d/99-sysctl.conf
	fi
	
	sudo sysctl -p
	echo "Forwarding IPs" >> log.txt
}