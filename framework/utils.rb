require "pathname"
require "uri"
require "digest"
require "fileutils"

module PACKMAN
  def self.does_command_exist? cmd
    `which #{cmd} 2>&1`
    return $?.success?
  end

  def self.download root, url, rename = nil, cmd = nil
    cmd ||= ConfigManager.download_command
    FileUtils.mkdir root if not Dir.exist? root
    if not does_command_exist? cmd
      CLI.report_error "Download command #{CLI.red cmd} does not exist!"
    end
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
    if not does_command_exist? 'git'
      CLI.report_error "#{CLI.red 'git'} does not exist!"
    end
    args = "-b #{tag} #{url} #{root}/#{rename}"
    system "git clone #{args}"
  end

  def self.class_defined?(class_name)
    Kernel.const_defined? class_name.to_s
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
    @@dir_stack.delete_at(@@dir_stack.size-1)
  end

  def self.work_in dir
    CLI.report_error 'No work block is given!' if not block_given?
    PACKMAN.cd dir
    yield
    PACKMAN.cd_back
  end

  def self.grep file_path, pattern
    content = File.open(file_path, 'r').read
    content.scan(pattern)
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
