module PACKMAN
  def self.cp src, dest
    FileUtils.cp_r src, dest
  end

  def self.mv src, dest
    FileUtils.mv src, dest
  end

  def self.rm file_path
    FileUtils.rm_rf Dir.glob(file_path), :secure => true
  end

  def self.ln src, dst
    FileUtils.ln_s src, dst
  end

  def self.mkdir dir, options = []
    options = [options] if not options.class == Array
    FileUtils.rm_rf(dir) if Dir.exist? dir and options.include? :force
    if not Dir.exist? dir
      begin
        FileUtils.mkdir_p(dir)
        CLI.report_notice "Create directory #{CLI.green dir}." if not options.include? :silent
      rescue => e
        CLI.report_error "Failed to create directory #{CLI.red dir}!\n"+
          "#{CLI.red '==>'} #{e}"
      end
    end
    if block_given?
      FileUtils.chdir(dir)
      yield
    end
  end

  def self.is_directory_empty? dir_path
    Dir.glob("#{dir_path}/*").empty?
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
end