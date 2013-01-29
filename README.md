```
                                                                            
                                Core Switch              ###
                                    |____________________### ninja firewall
                                    |                    ###
                                    |
                      |-------------|-------------|
                     SW1           SW2           SWX
                      |             |             |
                     ###           ###           ###
                FW1  ###       FW2 ###       FWX ###
                     ###           ###           ###
                                        
```





Ninja Firewall
==============
Spare Firewall is a standby Linux machine with (CentOS) distribution. The core of spare firewall is “ninja firewall” application which is manage the whole recovering process once employee run it without no need for anymore interaction from him. Ninja firewall application has been written by Ruby programming language it supports Ruby 1.8.x and Ruby 1.9.x versions.

*How does it work?*
-------------------
Ninja firewall application restores last current update network and iptables configurations files after make sure from closing customer's firewall's port on it's switch in order to guarantee avoidance of any MAC conflict or any unexpected return for the recovered firewall.
If we describe the technical steps of ninja firewall work , it'll be like following steps:

1. Log-in to customer switch.
2. Disable the down firewall's port.
3. Extract firewall's backup which has been taken periodically from each firewall to /ninja-firewall/backup/customer_name.tar.gz
4. recovering all network configuration and iptables rules 
5. check file recovering integrity use MD5 hash 
6. change spare firewall MAC address to the recovered firewall's MACs (to avoid confusing servers).
7. Restart network and iptables services to make sure from applying the changes.
8. Log each Success or failure in log/ninja-firewall.log file  .
9. Ninja-firewall has configuration file to make adding new customers is very simple task.
10. Ninja-firewall is capable to work with all RHEL/CentOS systems
11. Ninja-firewall support HP & Huwaie Switches commands 

*How to use?*
--------------
Simplicity was the key of using such application 

- help menu (-h or --help):

```
ruby ninja-firewall.rb -h
Usage: ruby ninja-firewall.rb -c CUSTOMER -u USERNAME -p PASSWORD                                                                                                  
    	-c, --customer CUSTOMER          mention One customer(which is down now!) name. MANDATORY
    	-u, --user USERNAME              mention Username of customer's switch. MANDATORY
    	-p, --pass PASSWORD              mention Password of customer's switch. MANDATORY
    	-l, --list                       List all available customers.
    	-r, --reset                      Reset ninja firewall system to original status.
    	-h, --help                       Display this screen
```

- List all available customers (-l or –list):

```
ruby  ninja-firewall.rb -l
------------------------
[+] Available Customers:
------------------------
[-] Customer1
[-] Customer2
[-] CustomerN
```


- Run the script in recovery mode 

```
ruby  ninja-firewall.rb -c $customer_name -u $username -p $password
```

which is
$cutomer_name: is the customer's name.
$username: is the customer's switch username.
$password: is the customer's switch password.


**The Result**

The solution has been done and we test the Scenario which Identical with AOT's real environment with success result.


**Trouble shooting**
* Make sure that all customers VLANs are exist on customer's router & switch.
* Make sure that both Spare firewall interfaces are trunk from the core switch
* Make sure Spare firewall has enable forwarding by default.
* Make sure Spare firewall has unique management VLAN  ID
* Make sure to reset Spare Firewall once customer issue become solved (reset.sh file)
* Make sure from Switch user name and password


**Future Features**
* Add reset mode: to reset Spare Firewall to it's original status.
* Improving logs file: supporting connections status.
* Add automated check.
* Full Automating: zero human control.
* Supporting more Switches (if required).
* Supporting SSH connections to switches.



