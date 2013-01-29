
gems = %w{rubygems colorize logger fileutils digest/md5} ; gems.each  { |gem| require gem }

$mark_Red      = "[+]".red
$mark_Red_m    = "[-]".red
$OK_Green      = "OK".green
$mark_Green    = "[+]".green
$mark_Green_m  = "[-]".green
$mark_Green_s  = "[*]".green
$mark_yellow   = "[+]".yellow
$warning       = "/!\\".yellow

##################################


def logger
  log = Logger.new("#{APP_ROOT}/log/ninja-firewall.log", 10, 1024000) 		# Filename: ninja-firewall.log , Number of rotation: 10 , Rotation Size= 125MB
end
ParseConfig.new('./config.conf')

class Restore 
  attr_accessor :file_name							# filename = customer name
  
  def initialize (file_name)
    @file_name = file_name
    
    case file_name
      when File.exists?(file_name) == true
	puts "#{$mark_Green} File exist"
	logger.info "#{file_name} file is exist!"
      when File.exists?(file_name) == false
	puts "#{$mark_Red} File is not exist"
	logger.error "#{file_name} file is not exist!"
	exit!		# Back to prompt
    end
    
  end
  
  def extract(tar_file = file_name.concat(".tar.gz")) 				# Extract(untar) Customer's backup file (customer_name.tar.gz)
    if File.exist?("#{BKP}/#{tar_file}") == false
      puts "\n#{$mark_Red} Backup file is not exist." + 
	   "\nMake sure backup file is in backup/ with customer-name.tar.gz"
      logger.error "#{tar_file} file is not exist!"
      exit
    else
      sleep 0.3
      puts "#{$mark_Green} Extracting.."
      sleep 0.2
      `tar -xzf  #{BKP}/#{tar_file} -C #{BKP}/`
    end
    
    puts "#{$mark_Green_s} Checking extracted files.."
    sleep 0.2
    
    untard = tar_file.chomp(".tar.gz")
    if  File.directory?("#{BKP}/#{untard}") && File.directory?("#{BKP}/#{untard}/network") && File.file?("#{BKP}/#{untard}/iptables")
      puts "#{$mark_Green_m} Extracting status\t\t\t[ #{$OK_Green} ] "
      logger.info "Files have been extraced successfully"
    else
      puts $mark_Red + " Folder '#{untard}' not found!. I can't pass you to restore level"
      logger.error "Folder '#{untard}' not found!. check your backup files manually"
      exit
    end
    sleep 0.1
    restore (untard)
  end
  
  def restore(untard)								# Overwirte current configuration ( 1- interfaces. 2- network file. 3- iptables.)
    puts "\n#{$mark_Green}" + " Adding route to 10.20.20.0/24"
    system("route add -host 10.20.20.127  dev eth0.501") 		# add route to keep mgmt up
    
    puts "\n#{$mark_Green} Restoring.."
    sleep 0.3
    
    #--> Restore Interfaces' configuration files
    puts "#{$mark_Green_s} Restoring network files"
    
    # Set directories 
    net_bkp   = "#{BKP}/#{untard}/network/"
    Dir.chdir(net_bkp)
    @@eth_bkp = Dir.glob('ifcfg-eth*')						# find ifcfg-eth* file and put it in array    
    @@net_sys = "#{SYSCONF}/network-scripts/"
    
    
    @@eth_bkp.each do |ifcfg| 					
      ethx = ifcfg.gsub(/[ifcfg-]/,'')
      eth_cfg = ParseConfig.new(ifcfg)						# Read the MAC from each ifcfg-ethx file,
      mac = "#{eth_cfg.params['HWADDR']}".to_s					# Then store it ex. "00:11:22:33:44:55"

      FileUtils.cp_r(ifcfg , @@net_sys , :remove_destination => true)		# then copy it. real path
      
      system("sed -i 's/HWADDR/#HWADDR/g' #{@@net_sys}#{ifcfg}")  if mac.to_s.empty? == false	# Comment MAC address configuration. real path
      system("ifup #{ethx}") if mac.to_s.empty? == true				# load VLANs up
      puts "[^]".green + " Setting MAC of " + "#{ethx}".green + "\t\t\t[ #{$OK_Green} ]" if mac.to_s.empty? == false
      system("ifconfig #{ethx} hw ether  #{mac.to_s}")          if mac.to_s.empty? == false	# change MAC
      
      begin
	if md5(File.read(ifcfg) , File.read("#{@@net_sys}/#{ifcfg}")) == false

	  if mac.to_s.empty? == true						# Quit ifcfg dosn't have MAC & MD5 has been changed
	    puts $mark_Red + " #{ifcfg} Unsuccessful Copy process!"
	    logger.error "#{ifcfg} file is not correct!"
	    exit
	  elsif mac.to_s.empty? == false
	    puts $mark_Green_m + " #{ifcfg}\t\t\t\t[ #{$OK_Green} ]"
	    logger.info "#{ifcfg} file has been copied successfully!"
	  end
	  
	else
	  puts $mark_Green_m + " #{ifcfg}\t\t\t[ #{$OK_Green} ]"
	  logger.info "#{ifcfg} file has been copied successfully!"
	end
	
      rescue
	puts $mark_Red_m + " #{ifcfg} Unsuccessful Copy process!!"
	logger.error "#{ifcfg} file is not correct! File is not exist"
	exit
      end
      
    end
    
    #--> Restore /etc/sysconfig/network
    puts "\n#{$mark_Green_s} Restoring network file.."
    sleep 0.3
    FileUtils.cp_r("network" ,"#{SYSCONF}/" , :remove_destination => true)
    if md5(File.read("network") , File.read("#{SYSCONF}/network")) == false
      puts $mark_Red + " network file has been copied Unsuccessful! check it manually"
      logger.error "network file is not correct!"
      exit
    else
      puts $mark_Green_m + " restoring network status\t\t\t[ #{$OK_Green} ]"
      logger.info "network file has been copied successfully!"
    end
    
    #--> Restore iptables
    puts "\n#{$mark_Green_s} Restoring iprables file.."
    sleep 0.3
    FileUtils.cp_r("#{BKP}/#{untard}/iptables" ,"#{SYSCONF}" , :remove_destination => true)
    
    if md5(File.read("#{BKP}/#{untard}/iptables") , File.read("#{SYSCONF}/iptables")) != true
      puts $mark_Red + " iptables file has been copied Unsuccessful! check it manually"
      logger.error "iptables file is not correct!"
      exit
    else
      puts $mark_Green_m + " restoring rules status\t\t\t[ #{$OK_Green} ]"
      logger.info "iptables file has been copied successfully!"
    end
 
  service									# restart services now :)
  end # restore
  
  def service									# Restart required services ( 1- network. 2- iptables )
    puts "\n#{$mark_Green} Restarting.."
    sleep 0.3
    puts "#{$mark_Green_m} Restarting network service"
    sleep 0.2
    system('/etc/init.d/network restart')
    system("route add -host 10.20.20.127 dev eth0.501") 		# add route to keep mgmt up
    puts "#{$mark_Green_m} Restarting iptables service"
    sleep 0.2
    system('/etc/init.d/iptables restart')
        
  end # service
    
  def md5(src , dst)								# Check file integrity !
    case
      when Digest::MD5.hexdigest(src) == Digest::MD5.hexdigest(dst)
	return true
      when Digest::MD5.hexdigest(src) != Digest::MD5.hexdigest(dst)
	return false
    end
  end # md5
  
end # Restore
  
