require 'rubygems' 
require 'parseconfig'

$conf = ParseConfig.new('./config.conf')

class Switch

  attr_accessor :cust_sw
  def initialize(customer) 	# type is: Switch type   ,  port is: tcp port  Customer_class(All should be from config file)
    @cust_sw = customer
  end
  
  
  
  def cmds (type = @cust_sw.info["sw_type"])	# it taks switch type from the class
    cmd = case type
	  when "hp" 
	    then
	       {"sudo"      => "configure terminal", 					#1 Previlige Escalation
		"ifconfig"  => "interface #{@cust_sw.info["ether"]}", 			#2 Interface Level
		"ifup"      => "enable", 						#3 Enable port
		"ifdown"    => "disable", 						#4 Disable port
		"ifstat"    => "show interfaces brief #{@cust_sw.info["ether"]}", 	#5 Display Port Status
		"clsMAC"    => "clear arp", 						#6 Clear MAC table
		"Exit"      => "exit", 							#7 previus step
		"Quit"      => "logout", 						#7 quit
		"Quit1"      => "quit" 							#7.1 quit (Old hp)
		}
	       
	  when "oldhp" 
	    then
	       {#"sudo"      => "configure terminal", 					#1 Previlige Escalation
	        "sudo"      => "enable", 						#1 Previlige Escalation
		"ifconfig"  => "interface #{@cust_sw.info["ether"]}", 			#2 Interface Level
		"ifup"      => "enable", 						#3 Enable port
		"ifdown"   => "shutdown",				 		#4 Disable port (Old hp)
		"ifstat"   => "do show interfaces #{@cust_sw.info["ether"]}", 		#5  Display Port Status (Old hp)
		"clsMAC"   => "clear mac-address-table", 				#6 Clear MAC table (Old hp)
		"Exit"      => "exit", 							#7 previus step
		}
	       
	  when "hu"
	    then
	      {"sudo"     => "system-view", 						#0 Previlige Escalation
	      "ifconfig" => "Int #{@cust_sw.info["ether"]}", 				#1 Interface Level
	      "ifdown"   => "Shut", 							#2 Shutdow
	      "ifup"     => "Un Shut", 							#3 Undo Shutdow
	      "ifstat"   => "Dis b int #{@cust_sw.info["ether"]}", 			#4 Interface Status
	      "clsMAC"   => "How to clear the ARP cache", 				#5 Clear MAC table
	      "Quit"     => "quit" 							#6 quit
	      }
      end
      return cmd
  end # cmd
end	# End of class Type 


class Customer
  attr_accessor :name, :user, :pass

  def initialize (name , user , pass)
    @name = name
    @user = user
    @pass = pass
  end
  
  def info(get_cust = @name ) #, user , pass)
    id 	      = $conf.params[get_cust]['id']
    name      = $conf.params[get_cust]['cust_name']
    ip        = $conf.params[get_cust]['ip']
    port      = $conf.params[get_cust]['port']
    sw_type   = $conf.params[get_cust]['sw_type']
    ether     = $conf.params[get_cust]['ether']
    info_map  = {"id" => id ,"name" => name, "ip" => ip , "port" => port, "sw_type" => sw_type , "ether" => ether}	# Return them in Hash ;)
  end
###############################################################################################################
#   cust_name = $conf.params[get_cust?]['name']		# User input  c.params[customer_name]['name']
#   id        = $conf.params[get_cust?]['id']		# config file: c.params[customer_name]['id']
#   ip        = $conf.params[get_cust?]['ip']		# config file: c.params[customer_name]['ip']
#   port      = $conf.params[get_cust?]['ip']		# config file: c.params[customer_name]['port']
#   user      = $conf.params[get_cust?]['user']		# User input
#   pass      = $conf.params[get_cust?]['pass']		# User input
#   sw_type   = $conf.params[get_cust?]['sw_type']	# config file: c.params[customer_name]['sw_type']
#   eth_port  = $conf.params[get_cust?]['ether']	# config file: c.params[customer_name]['ether']
###############################################################################################################
end




##customer#############################
# customer = Customer.new("seder")
# puts customer.info
# puts customer.info["id"]
# puts customer.info["ip"]
# puts customer.info["sw_type"]
# puts customer.info["ether"]
######################################

##Switch###############################
# switch = Switch.new("hp" , 23)
# puts switch.type
# puts switch.port
# puts switch.cmds
# puts switch.cmds["sudo"]
######################################


