require "pathname"
require "uri"
require "digest"
require "fileutils"

module PACKMAN
  def self.check_command cmd
    `which #{cmd} 2>&1`
    if not $?.success?
      raise "Command \"#{cmd}\" does not exist!"
    end
  end

  def self.download root, url, rename = nil, cmd = nil
    cmd ||= ConfigManager.download_command
    FileUtils.mkdir root if not Dir.exist? root
    check_command cmd
    filename = rename ? rename : File.basename(URI.parse(url).path)
    case cmd
    when :curl
      system "curl -f#L -C - -o #{root}/#{filename} #{url}"
    when :wget
      system "wget -O #{root}/#{filename} -c #{url}"
    end
    if not $?.success?
      if cmd == :curl
        # Use wget instead.
        CLI.report_warning 'Curl failed! Try to use wget.'
        download root, url, rename, :wget
        return
      end
      case $?.exitstatus
      when 23
        CLI.report_error "Failed to create file in #{CLI.red root}!"
      end
      if ConfigManager.use_ftp_mirror == 'no'
        if NetworkManager.is_connect_internet?
          CLI.report_error "Failed to download #{CLI.red url}!"
        else
          CLI.report_error "This machine can not connect internet! You may use a FTP mirror in your location."
        end
      else
        if NetworkManager.is_connect_internet?
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
        CLI.report_warning "Directory #{filepath} SHA1 is #{current}."
        return false
      end
    else
      CLI.report_error "Unknown file type \"#{filepath}\"!"
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
      CLI.report_error "Unknown compression type of \"#{filepath}\"!"
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

  def self.cd dir, options = []
    options = [options] if not options.class == Array
    @@dir_stack ||= []
    @@dir_stack << FileUtils.pwd if not options.include? :norecord
    FileUtils.chdir dir
  end

  def self.cd_back
    CLI.report_error 'There is no more directory to change back!' if @@dir_stack.empty?
    FileUtils.chdir @@dir_stack.last
    @@dir_stack = @@dir_stack[0..-1]
  end

  def self.work_in dir
    CLI.report_error 'No work block is given!' if not block_given?
    PACKMAN.cd dir
    yield
    PACKMAN.cd_back
  end

  def self.cp src, dest
    FileUtils.cp_r src, dest
  end

  def self.mv src, dest
    FileUtils.mv src, dest
  end

  def self.replace file_path, replaces
    content = File.open(file_path, 'r').read
    replaces.each do |pattern, replacement|
      if content.gsub!(pattern, replacement) == nil
        CLI.report_error "Pattern \"#{pattern}\" is not found in \"#{file_path}\"!"
      end
    end
    file = File.open file_path, 'w'
    file << content
    file.close
  end

  def self.grep file_path, pattern
    content = File.open(file_path, 'r').read
    content.scan(pattern)
  end

  def self.decompress file_path
    case PACKMAN.compression_type file_path
    when :tar_Z
      system "tar xzf #{file_path}"
    when :tar
      system "tar xf #{file_path}"
    when :gzip
      system "gzip -d #{file_path}"
    when :bzip2
      system "bzip2 -d #{file_path}"
    when :zip
      system "unzip -o #{file_path} 1> /dev/null"
    end
  end

  def self.rm file_path
    FileUtils.rm_rf Dir.glob(file_path), :secure => true
  end

  def self.ln src, dst
    FileUtils.ln_s src, dst
  end

  def self.strip_dir dir, level
    for i in 1..level
      dir = File.dirname dir
    end
    return dir
  end

  def self.expand_tilde path
    path.gsub! '~', Dir.home
  end
end
