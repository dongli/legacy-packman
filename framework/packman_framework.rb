Dir.glob("#{ENV['PACKMAN_ROOT']}/framework/*.rb").each do |file|
  next if file =~ /packman_framework.rb$/
  require file
end

PACKMAN::OS.scan
PACKMAN::ConfigManager.init
