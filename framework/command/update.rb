module PACKMAN
  class Commands
    def self.update
      PACKMAN.cd ENV['PACKMAN_ROOT']
      begin
        if Dir.exist? '.git'
          update_by_using_git
        else
          update_by_direct_download
        end
      rescue => e
        if not OS.connect_internet?
          if ConfigManager.use_ftp_mirror == 'no'
            CLI.report_error "This machine can not connect internet! "+
              "You may use a FTP mirror in your location.\n"+
              "#{CLI.red '==>'} #{e}"
          else
            CLI.report_error "This machine can not connect internet, "+
              "but FTP mirror is used. I am working on it!\n"+
              "#{CLI.red '==>'} #{e}"
          end
        end
      end
      PACKMAN.cd_back
    end

    def self.update_by_using_git
      system 'git pull'
    end

    def self.update_by_direct_download
      # Read the current version tag.
      version_file = "#{ENV['PACKMAN_ROOT']}/.version"
      if File.exist? version_file
        current_version = File.open(version_file, 'r').read.strip
      else
        current_version = nil
        CLI.report_warning "#{CLI.red version_file} does not exist!"
      end
      url = 'https://api.github.com/repos/dongli/packman/tags'
      begin
        tags = eval `curl -s #{url}`.gsub(': ', ' => ')
        latest_version = tags.first['name']
        latest_tarball_url = tags.first['tarball_url']
      rescue => e
        CLI.report_error "Failed to retrieve information from #{url}!\n#{CLI.red '==>'} #{e}"
      end
      if current_version != latest_version
        tarball = "#{File.basename(URI.parse(latest_tarball_url).path)}.tar.gz"
        CLI.report_notice "There is new version (#{CLI.green latest_version}) available."
        CLI.report_notice "Download #{CLI.green latest_tarball_url}."
        tmp_dir = "#{ENV['PACKMAN_ROOT']}/../.packman-tmp"
        PACKMAN.mkdir tmp_dir, :force
        PACKMAN.cd tmp_dir
        PACKMAN.download '.', latest_tarball_url, tarball
        PACKMAN.decompress tarball
        dec_dir = (Dir.glob('*').reject { |x| x == tarball }).first
        # Save the user customized config file.
        if File.exist? "#{ENV['PACKMAN_ROOT']}/packman.config"
          PACKMAN.cp "#{ENV['PACKMAN_ROOT']}/packman.config", dec_dir
        end
        PACKMAN.rm ENV['PACKMAN_ROOT']
        PACKMAN.mv dec_dir, ENV['PACKMAN_ROOT']
        PACKMAN.cd_back
        PACKMAN.rm tmp_dir
      else
        CLI.report_notice "PACKMAN #{CLI.blue current_version} is up-to-date."
      end
    end
  end
end
