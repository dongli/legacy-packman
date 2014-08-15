Dir.glob("#{ENV['PACKMAN_ROOT']}/packages/*.rb").each do |file|
  next if file =~ /packman_packages.rb$/
  require file
end
