require "pathname"
require "uri"
require "digest"
require "fileutils"

module PACKMAN
  class Tty
    class << self
      def blue; color 34; end
      def white; color 39; end
      def red; color 31; end
      def yellow; color 33; end
      def reset; escape 0; end
      def em; underline 39; end
      def green; color 32; end
      def gray; color 30; end

      def width
        `/usr/bin/tput cols`.strip.to_i
      end

      def truncate(str)
        str.to_s[0, width - 4]
      end

      def bold(str)
        escape(1)+str+escape(0) 
      end

      private

      def color n
        escape "0;#{n}"
      end
      def underline n
        escape "4;#{n}"
      end
      def escape n
        "\033[#{n}m" if $stdout.tty?
      end
    end
  end

  def self.report_notice(message)
    print "[#{Tty.green}Notice#{Tty.reset}]: #{message}\n"
  end

  def self.report_warning(message)
    print "[#{Tty.yellow}Warning#{Tty.reset}]: #{message}\n"
  end

  def self.report_error(message)
    print "[#{Tty.red}Error#{Tty.reset}]: #{message}\n"
    exit
  end

  def self.report_check(message)
    print "[#{Tty.red}CHECK#{Tty.reset}]: #{message}\n"
  end

  def self.under_construction!
    print "Oops: PACKMAN is under construction!\n"
    exit
  end

  def self.check_command(cmd)
    `which #{cmd}`
    if not $?.success?
      raise "Command \"#{cmd}\" does not exist!"
    end
  end

  def self.download(root, url, rename = nil)
    check_command('curl')
    filename = File.basename(URI.parse(url).path)
    if rename
      args = "-f#L -C - -o #{root}/#{rename}"
    else
      args = "-f#L -C - -o #{root}/#{filename}"
    end
    system "curl #{args} #{url}"
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
        report_warning "Directory #{filepath} SHA1 is #{current}."
        return false
      end
    else
      report_error "Unknown file type \"#{filepath}\"!"
    end
  end

  def self.compression_type(filepath)
    if filepath =~ /\.(tar(\..*)?|tgz|tbz2)$/
      return :tar
    elsif filepath =~ /\.(gz)$/
      return :gzip
    elsif filepath =~ /\.(bz2)$/
      return :bzip2
    elsif filepath =~ /\.(zip)$/
      return :zip
    else
      PACKMAN.report_error "Unknown compression type of \"#{filepath}\"!"
    end
  end

  def self.append(filepath, lines)
    File.open(filepath, "a") { |file|  file << lines }
  end

  def self.mkdir(dir, option = :none)
    FileUtils.rm_rf(dir) if Dir.exist?(dir) and option == :force
    FileUtils.mkdir_p(dir)
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

  def self.new_class(class_name)
    if class_name == ''
      report_error "Empty class!"
    end
    if not PACKMAN.class_defined? class_name
      report_error "Unknown class #{Tty.red}#{class_name}#{Tty.reset}!"
    end
    eval "#{class_name}.new"
  end

  def self.decompress(filepath)
    case PACKMAN.compression_type filepath
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
end
