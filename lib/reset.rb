

# to reset ninja firewall 
class Reset
  def initialize 
    @@net_sys = "#{SYSCONF}/network-scripts/"
    @@nfw_bkp   = "#{BKP}/nfw-bkp/"
    system("tar -xzf #{BKP}/nfw-bkp.tar.gz")
  end
  
  def clean
    puts $mark_Red + " Deleting.."
    puts $mark_Red_m + " ifcfg-eth files"
    puts $mark_Red_m + " network file"
    puts $mark_Red_m + " iptables file"
    File.delete("#{@@net_sys}ifcfg-eth0*", "#{@@net_sys}ifcfg-eth1*" , "#{SYSCONF}network" , "#{SYSCONF}iptables")
  end
  
  def reset
#     clean

    puts $mark_Red + " Resetting.."
    puts $mark_Red_m + " ifcfg-eth files"
    FileUtils.cp_r("#{@@nfw_bkp}ifcfg-eth0" , @@net_sys , :remove_destination => true)
    FileUtils.cp_r("#{@@nfw_bkp}ifcfg-eth1" , @@net_sys , :remove_destination => true)
    puts $mark_Red_m + " network file"
    FileUtils.cp_r("#{@@nfw_bkp}network"    , SYSCONF   , :remove_destination => true)
    puts $mark_Red_m + " iptables file"
    FileUtils.cp_r("#{@@nfw_bkp}iptables"   , SYSCONF   , :remove_destination => true)
    
#     FileUtils.cp_r("#{@@net_sys}ifcfg-eth0" , @@net_sys , :remove_destination => true)
#     FileUtils.cp_r("#{@@net_sys}ifcfg-eth1" , @@net_sys , :remove_destination => true)
#     FileUtils.cp_r("#{@@nfw_bkp}network"    , SYSCONF   , :remove_destination => true)
#     FileUtils.cp_r("#{@@net_sys}iptables"   , SYSCONF   , :remove_destination => true)
    
    puts "\n-------------------------------------------------------------------------".yellow
    puts " #{$warning} " + "NOTE: You have to REBOOT the system MANIUALLY to apply the changes!".red
    puts "-------------------------------------------------------------------------\n".yellow
  end
end
