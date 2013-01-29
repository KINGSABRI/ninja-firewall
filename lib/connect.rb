gems = %w{rubygems colorize net/telnet logger} ; gems.each  { |gem| require gem }

# def logger
#   logger = Logger.new('logs/ninjaFW.log', 10, 10240) # Filename: ninjaFW.log , Number of rotation: 10 , Rotation Size= 10MB
# end


class Connect
  attr_accessor :switch 
  def initialize(switch)
     @switch = switch
    if switch.cust_sw.info["sw_type"]     == "hp"
      hp_connect(switch)
    elsif switch.cust_sw.info["sw_type"]  == "oldhp"
      oldhp_connect(switch)
    elsif switch.cust_sw.info["sw_type"]  == "hu"
      huwaei_connect(switch)
    else
      puts "Your Switch type is not supported!"
      exit
    end
  end

  def hp_connect(switch)
    
    #--> Connection Settings 
    s = Net::Telnet::new("Host" => switch.cust_sw.info["ip"] ,"Port" => switch.cust_sw.info['port'] ,"Timeout" => 130)
    sleep 0.4
    s.write "\r\n" #if switch.cust_sw.info["name"] == "mudifer" || "investor"
    s.puts(switch.cust_sw.user)
    s.puts(switch.cust_sw.pass)
    
    #--> Let's to execute 
    s.cmd(switch.cmds["sudo"]) 	          do |l0|		# Priv escalation
      print l0
      s.cmd(switch.cmds["ifconfig"])	  do |l1|		# Interface level config
	print l1
	s.cmd(switch.cmds["ifdown"])  	  do |l2|		# Interface up
	  print l2
# 	  s.cmd(switch.cmds["clsMAC"])	  do |l3|		# Dangerus!!! ,,
# 	    print l3
# 	  end
	  s.cmd(switch.cmds["Quit"])	do |lq|			# Quit
	    if lq.inspect.include? "Do you want to log out"
	      s.print "y"
	    end
	    if lq.inspect.include? "Do you want to save current configuration"
	      s.print "y"
	    end
	  end	#l3
	end	#l2
      end	#l1
      puts "\r\n"
    end		#l0

#     puts "Customer name: #{switch.cust_sw.info["name"]}"
#     puts "username:      #{switch.cust_sw.user}" 
#     puts "password:      #{switch.cust_sw.pass}"
#     puts "Switch Type:   #{switch.cust_sw.info["sw_type"]}"
#     puts "Switch IP:     #{switch.cust_sw.info["ip"]}"
#     puts "Switch port:   #{switch.cust_sw.info["port"]}"
#     puts "Switch ether:  #{switch.cust_sw.info["ether"]}"
#     puts "Switch cmd:    #{switch.cmds["sudo"]}"
  end

  def oldhp_connect(switch)
    
    #--> Connection Settings 
    s = Net::Telnet::new("Host" => switch.cust_sw.info["ip"] ,"Port" => switch.cust_sw.info['port'] ,"Timeout" => 130)
    sleep 0.4
    s.puts(switch.cust_sw.user)
    s.puts(switch.cust_sw.pass)
    
    #--> Let's to execute 
    s.cmd(switch.cmds["sudo"]) 	          do |l0|		# Priv escalation
      print l0
      s.cmd(switch.cmds["ifconfig"])	  do |l1|		# Interface level config
	print l1
	s.cmd(switch.cmds["ifstat"])  	  do |l2|		# Interface up
	  print l2
# 	  s.cmd(switch.cmds["clsMAC"])	  do |l3|		# Dangerus!!! ,,
# 	    print l3
# 	  end
	  s.puts "exit"
	  s.cmd(switch.cmds["Exit"])	  do |lq|			# Quit
	     s.cmd(switch.cmds["Exit"])	  do |lq|
	       print lq
	       s.cmd(switch.cmds["Exit"]) {|lq| print lq}
	     end #lq
	    end  #lq
	  end	 #l3
	end	 #l2
      end	 #l1
      puts "\r\n"
    end		#l0

  def huwaei_connect(switch)
    
#     #--> Connection Settings 
    s = Net::Telnet::new("Host" => switch.cust_sw.info["ip"] ,"Port" => switch.cust_sw.info["port"] ,"Timeout" => 130)
    sleep 0.5
    s.puts(switch.cust_sw.user)
    s.puts(switch.cust_sw.pass)

    #--> Let's to execute
    s.cmd(switch.cmds["sudo"])         do |l0|	# Priv escalation
      print l0
      s.cmd(switch.cmds["ifconfig"])   do |l1|	# Interface config level
	print l1
	s.cmd(switch.cmds["ifdown"])   do |l2|  # ifup/ifdown
	  print l2
	  s.cmd(switch.cmds["ifstat"]) do |l3|	# ifstatus , should be clear ARP cache
  	    print l3
	    s.cmd(switch.cmds["Quit"]) do |q|	# Quit
	      print q				# Quit l3
	      s.puts "quit"			# Quit l2
	    end
	    print "\r\n"
	    s.puts "quit"
	  end		# l3
	  s.cmd(switch.cmds["Quit"])   do |q|	# Quit
	    print "\r\n"
	    s.puts "quit"			# Quit l1,l0
	  end
	end		# l2
      end		# l1
    end			# l0
	
    puts "Customer name: #{switch.cust_sw.info["name"]}"
    puts "username:      #{switch.cust_sw.user}" 
    puts "password:      #{switch.cust_sw.pass}"
    puts "Switch Type:   #{switch.cust_sw.info["sw_type"]}"
    puts "Switch IP:     #{switch.cust_sw.info["ip"]}"
    puts "Switch port:   #{switch.cust_sw.info["port"]}"
    puts "Switch ether:  #{switch.cust_sw.info["ether"]}"
    puts "Switch cmd:    #{switch.cmds["sudo"]}"
      puts "\r\n"
  end
  
  puts "\r\n"
end

