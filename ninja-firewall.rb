#!/usr/bin/ruby
###################################################################
#### "  _  _ _       _        ___ _                     _ _  " ####
#### " | \| (_)_ _  (_)__ _  | __(_)_ _ _____ __ ____ _| | | " ####
#### " | .` | | ' \ | / _` | | _|| | '_/ -_) V  V / _` | | | " ####
#### " |_|\_|_|_||_|/ \__,_| |_| |_|_| \___|\_/\_/\__,_|_|_| " ####
#### "            |__/                                       " ####
###################################################################
#### Coded by: Sabry Saleh				       ####
#### Last update: 					       ####
#### License: GPL3					       ####
#### Version: 1.0 beta final				       ####
###################################################################
#
# gem install colorize logger optparse pp parseconfig
#
gems = %w{rubygems colorize logger fileutils optparse pp parseconfig} ; gems.each  {|gem| require gem}
#--> Setup Directories 
APP_ROOT = Dir.pwd
ROOT = $:.unshift(File.join(APP_ROOT, "lib"))
require 'switch'
require 'restore'
require 'connect'
require 'reset'
BKP  = "#{APP_ROOT}/backup"
LOG  = "#{APP_ROOT}/log"
SYSCONF = "/etc/sysconfig"



# logger = Logger.new('log/ninjaFW.log', 10, 1024000) # Filename: ninjaFW.log , Number of rotation: 10 , Rotation Size= 125MB

$mark_Red      = "[+]".red
$mark_Red_m    = "[-]".red
$OK_Green      = "OK".green
$mark_Green    = "[+]".green
$mark_Green_m  = "[-]".green
$mark_Green_s  = "[*]".green
$mark_yellow   = "[+]".yellow
$warning       = "/!\\".yellow


#--> Banner
def banner
  version = "1.0".cyan
  print "
                  ||              ||              .'|.  ||                                      '||  '|| 
        .. ...   ...  .. ...     ...  ....      .||.   ...  ... ..    ....  ... ... ...  ....    ||   || 
         ||  ||   ||   ||  ||     || '' .||      ||     ||   ||' '' .|...||  ||  ||  |  '' .||   ||   || 
         ||  ||   ||   ||  ||     || .|' ||      ||     ||   ||     ||        ||| |||   .|' ||   ||   || 
        .||. ||. .||. .||. ||.    || '|..'|'    .||.   .||. .||.     '|...'    |   |    '|..'|' .||. .||.
                               .. |'                                                                     
                                ''  Version: #{version}
				
      \n".light_blue
end


$conf = ParseConfig.new('./config.conf')  # configuration file 

banner
options = {}

optparse = OptionParser.new do|opts|
  #--> Customer name
  opts.on('-c', '--customer CUSTOMER', String,"mention One customer(which is down now!) name. MANDATORY") do |c|
    options[:customer] = c
  end
  #--> username
  opts.on('-u', '--user USERNAME', "mention Username of customer's switch. MANDATORY") do |u|
    options[:user] = u
  end
  #--> password
  opts.on('-p', '--pass PASSWORD', "mention Password of customer's switch. MANDATORY") do |p|
    options[:pass] = p 
  end
  #--> list all customers
  options[:list] = false
  opts.on('-l', '--list', "List all available customers.") do |l|
    options[:list] = true
  end
  #--> reset ninja firewall system
  opts.on('-r', '--reset', "Reset ninja firewall system to original status.") do |r|
    options[:reset] = r
  end
  #--> Display the help screen
  opts.banner = "Usage: ruby ninja-firewall.rb -c CUSTOMER -u USERNAME -p PASSWORD"
  opts.on( '-h', '--help', "Display this screen " ) do	
    puts opts
    exit
  end
end
optparse.parse!
options
ARGV


def customers_list
    puts "\n"+ 
      "------------------------\n" +
      "#{$mark_Green} Available Customers"+":\n".green +
      "------------------------\n" 
    $conf.groups.each {|c| puts "#{$mark_Green_m} #{c.capitalize}"}
      
    puts "\nUsage: ruby ninja-firewall.rb -c CUSTOMER -u USERNAME -p PASSWORD".green
end


customer_i = options[:customer].to_s.downcase
username_i = options[:user].to_s
password_i = options[:pass].to_s


 
if options[:list]
  puts customers_list
elsif options[:customer].nil? || options[:user].nil? || options[:pass].nil? == true
  puts optparse
else
  #--> Stage 1
  puts "\n\n"
  puts "#{$warning}" + " Stage1: Network".green
  customer = Customer.new(customer_i , username_i , password_i)
  switch   = Switch.new(customer)
  connect  = Connect.new(switch)
  #--> Stage 2
  sleep 1.0
  puts "\n\n"
  puts "#{$warning}" + " Stage2: System".green
  restore = Restore.new(customer_i).extract
end
if options[:reset]
  options[:reset] = Reset.new.reset
end
  

# options[:reset] = Reset.new.reset


