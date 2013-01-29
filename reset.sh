#!/bin/bash

rm -rf  /etc/sysconfig/network-scripts/ifcfg-eth1
rm -rf  /etc/sysconfig/network-scripts/ifcfg-eth0 
rm -rf  /etc/sysconfig/network-scripts/ifcfg-eth1.*
rm -rf /etc/sysconfig/network-scripts/network
cp backup/ninja-firewall-server-backup/ifcfg-eth1       /etc/sysconfig/network-scripts/ifcfg-eth1 
cp backup/ninja-firewall-server-backup/ifcfg-eth0       /etc/sysconfig/network-scripts/ifcfg-eth0 
cp backup/ninja-firewall-server-backup/network          /etc/sysconfig/
cp backup/ninja-firewall-server-backup/ifcfg-eth0.501   /etc/sysconfig/network-scripts/

