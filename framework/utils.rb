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

  def self.check_command(cmd)
    `which curl`
    if not $?.success?
      report_error "Command \"#{cmd}\" does not exist!"
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

  def self.class_defined?(class_name)
    Kernel.const_defined?(class_name)
  end

  def self.sha1_same?(filepath, expect)
    target = Digest::SHA1.hexdigest(File.read(filepath))
    return target.eql? expect
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
end
