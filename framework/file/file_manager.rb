require "fileutils"

module PACKMAN
  def self.mkexe file
    FileUtils.chmod 0755, file
  end

  def self.cp src, dest
    Dir.glob(src).each do |file|
      FileUtils.cp_r file, dest
    end
  end

  def self.mv src, dest
    Dir.glob(src).each do |file|
      FileUtils.mv file, dest
    end
  end

  def self.rm file_path
    FileUtils.rm_rf Dir.glob(file_path), :secure => true
  end

  def self.ln src, dest
    Dir.glob(src).each do |file|
      FileUtils.ln_sf file, dest
    end
  end

  def self.mkdir dir, options = []
    options = [options] if not options.class == Array
    if Dir.exist? dir
      if options.include? :force
        FileUtils.rm_rf dir
      elsif options.include? :skip_if_exist
        return
      elsif not options.include? :silent
        CLI.report_error "Directory #{CLI.red dir} already exists!"
      end
    end
    begin
      FileUtils.mkdir_p(dir)
      CLI.report_notice "Create directory #{CLI.blue dir}." if not options.include? :silent
    rescue => e
      CLI.report_error "Failed to create directory #{CLI.red dir}!\n"+
        "#{CLI.red '==>'} #{e}"
    end
    if block_given?
      FileUtils.chdir(dir)
      yield
    end
  end

  def self.is_directory_empty? dir_path
    Dir.glob("#{dir_path}/*").empty?
  end

  def self.append file_path, lines
    File.open(file_path, "a") { |file|  file << lines }
  end

  def self.replace file_path, replaces, options = []
    options = [options] if not options.class == Array
    content = File.open(file_path, 'r').read
    replaces.each do |pattern, replacement|
      if content.gsub!(pattern, replacement) == nil
        if options.include? :silent
          exit
        else
          CLI.report_error "Pattern \"#{pattern}\" is not found in \"#{file_path}\"!" if not options.include? :not_exit
        end
      end
    end
    file = File.open file_path, 'w'
    file << content
    file.close
  end

  def self.delete_from_file file_path, patterns, options = []
    patterns = [patterns] if not patterns.class == Array
    options = [options] if not options.class == Array
    content = File.open(file_path, 'r').read
    patterns.each do |pattern|
      if content.gsub!(pattern, '') == nil and not options.include? :no_error
        CLI.report_error "Pattern \"#{pattern}\" is not found in \"#{file_path}\"!"
      end
    end
    file = File.open file_path, 'w'
    file << content
    file.close
  end

  def self.compression_type file_path, options = []
    options = [options] if not options.class == Array
    if file_path =~ /\.tar.Z$/i
      return :tar_Z
    elsif file_path =~ /\.(tar(\..*)?|tgz|tbz2)$/i
      return :tar
    elsif file_path =~ /\.(gz)$/i
      return :gzip
    elsif file_path =~ /\.(bz2)$/i
      return :bzip2
    elsif file_path =~ /\.(zip)$/i
      return :zip
    else
      if not options.include? :not_exit
        CLI.report_error "Unknown compression type of \"#{file_path}\"!"
      else
        return nil
      end
    end
  end

  def self.decompress file_path, options = []
    options = [options] if not options.class == Array
    CLI.report_notice "Decompress #{CLI.blue File.basename(file_path)}." if not options.include? :silent
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

  def self.sha1_same? file_path, expect
    if File.file? file_path
      expect.eql? Digest::SHA1.hexdigest(File.read(file_path))
    elsif File.directory? file_path
      tmp = []
      Dir.glob("#{file_path}/**/*").each do |file|
        next if File.directory? file
        tmp << Digest::SHA1.hexdigest(File.read(file))
      end
      current = Digest::SHA1.hexdigest(tmp.sort.join)
      if expect.eql? current
        return true
      else
        CLI.report_warning "Directory #{file_path} SHA1 is #{current}."
        return false
      end
    else
      CLI.report_error "Unknown file type \"#{file_path}\"!"
    end
  end
end
