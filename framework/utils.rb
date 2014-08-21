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

      private

      def color n
        escape "0;#{n}"
      end
      def bold n
        escape "1;#{n}"
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

  def self.download(root, url, rename = nil)
    curl = Pathname.new '/usr/bin/curl'
    raise "#{curl} is not executable" unless curl.exist? and curl.executable?
    filename = File.basename(URI.parse(url).path)
    if rename
      args = "-f#L -C - -o #{root}/#{rename}"
    else
      args = "-f#L -C - -o #{root}/#{filename}"
    end
    system "#{curl} #{args} #{url}"
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

  def self.mkdir(dir, is_force = false)
    FileUtils.rm_rf(dir) if Dir.exist?(dir) and is_force
    FileUtils.mkdir_p(dir)
    if block_given?
      FileUtils.chdir(dir)
      yield
    end
  end
end