require "pathname"
require "uri"
require "digest"
require "fileutils"

module PACKMAN
  def self.check_command cmd
    `which #{cmd}`
    if not $?.success?
      raise "Command \"#{cmd}\" does not exist!"
    end
  end

  def self.download root, url, rename = nil
    FileUtils.mkdir root if not Dir.exist? root
    check_command 'curl'
    filename = rename ? rename : File.basename(URI.parse(url).path)
    system "curl -f#L -C - -o #{root}/#{filename} #{url}"
    if not $?.success?
      case $?.exitstatus
      when 23
        CLI.report_error "Failed to create file in #{CLI.red root}!"
      end
      if ConfigManager.use_ftp_mirror == 'no'
        if OS.connect_internet?
          CLI.report_error "Failed to download #{CLI.red url}!"
        else
          CLI.report_error "This machine can not connect internet! You may use a FTP mirror in your location."
        end
      else
        if OS.connect_internet?
          CLI.report_error "FTP mirror failed to provide #{CLI.red filename}, you may consider to switch off mirror."
        else
          case $?.exitstatus
          when 78
            CLI.report_error "It seems that the FTP mirror does not have #{CLI.red filename}!"
          end
        end
      end
    end
  end

  def self.git_clone(root, url, tag, rename)
    if Dir.exist? "#{root}/#{rename}"
      FileUtils.rm_rf "#{root}/#{rename}"
    end
    check_command('git')
    args = "-b #{tag} #{url} #{root}/#{rename}"
    system "git clone #{args}"
  end

  def self.class_defined?(class_name)
    Kernel.const_defined? class_name.to_s
  end

  def self.sha1_same?(filepath, expect)
    if File.file? filepath
      expect.eql? Digest::SHA1.hexdigest(File.read(filepath))
    elsif File.directory? filepath
      tmp = []
      Dir.glob("#{filepath}/**/*").each do |file|
        next if File.directory? file
        tmp << Digest::SHA1.hexdigest(File.read(file))
      end
      current = Digest::SHA1.hexdigest(tmp.sort.join)
      if expect.eql? current
        return true
      else
        PACKMAN::CLI.report_warning "Directory #{filepath} SHA1 is #{current}."
        return false
      end
    else
      PACKMAN::CLI.report_error "Unknown file type \"#{filepath}\"!"
    end
  end

  def self.compression_type(filepath)
    if filepath =~ /\.tar.Z$/
      return :tar_Z
    elsif filepath =~ /\.(tar(\..*)?|tgz|tbz2)$/
      return :tar
    elsif filepath =~ /\.(gz)$/
      return :gzip
    elsif filepath =~ /\.(bz2)$/
      return :bzip2
    elsif filepath =~ /\.(zip)$/
      return :zip
    else
      PACKMAN::CLI.report_error "Unknown compression type of \"#{filepath}\"!"
    end
  end

  def self.append(filepath, lines)
    File.open(filepath, "a") { |file|  file << lines }
  end

  def self.mkdir(dir, options = [])
    options = [options] if not options.class == Array
    FileUtils.rm_rf(dir) if Dir.exist? dir and options.include? :force
    FileUtils.mkdir_p(dir) if not Dir.exist? dir
    if block_given?
      FileUtils.chdir(dir)
      yield
    end
  end

  def self.cd(dir)
    @@prev_dir = FileUtils.pwd
    FileUtils.chdir dir
  end

  def self.cd_back
    FileUtils.chdir @@prev_dir
  end

  def self.cp(src, dest)
    FileUtils.cp_r src, dest
  end

  def self.mv src, dest
    FileUtils.mv src, dest
  end

  def self.replace(filepath, replaces)
    content = File.open(filepath, 'r').read
    replaces.each do |pattern, replacement|
      if content.gsub!(pattern, replacement) == nil
        raise "Pattern \"#{pattern}\" is not found in \"#{filepath}\"!"
      end
    end
    file = File.open(filepath, 'w')
    file << content
    file.close
  end

  def self.grep file_path, pattern
    content = File.open(file_path, 'r').read
    content.scan(pattern)
  end

  def self.new_class(class_name)
    if class_name == ''
      PACKMAN::CLI.report_error "Empty class!"
    end
    if not PACKMAN.class_defined? class_name
      PACKMAN::CLI.report_error "Unknown class #{CLI.red class_name}!"
    end
    eval "#{class_name}.new"
  end

  def self.decompress(filepath)
    case PACKMAN.compression_type filepath
    when :tar_Z
      system "tar xzf #{filepath}"
    when :tar
      system "tar xf #{filepath}"
    when :gzip
      system "gzip -d #{filepath}"
    when :bzip2
      system "bzip2 -d #{filepath}"
    when :zip
      system "unzip -o #{filepath} 1> /dev/null"
    end
  end

  def self.rm(filepath)
    FileUtils.rm_rf filepath
  end

  def self.ln(src, dst)
    FileUtils.ln_s src, dst
  end

  def self.strip_dir dir, level
    for i in 1..level
      dir = File.dirname dir
    end
    return dir
  end
end
