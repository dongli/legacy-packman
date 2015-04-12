module PACKMAN
  class Commands
    def self.update
      PACKMAN.work_in ENV['PACKMAN_ROOT'] do
        if NetworkManager.is_connect_internet?
          if Dir.exist? '.git'
            update_by_using_git
          else
            update_by_direct_download
          end
        else
          if ConfigManager.use_ftp_mirror != 'no'
            update_by_using_ftp
          else
            CLI.report_error "This machine can not connect internet! "+
              "You may use a FTP mirror in your location."
          end
        end
      end
    end

    def self.update_by_using_git
      repos = `git remote`
      if repos.include? 'gitcafe'
        CLI.report_notice 'Update from PACKMAN GitCafe repository.'
        system 'git pull gitcafe master'
      else
        CLI.report_notice 'Update from PACKMAN GitHub repository.'
        system 'git pull'
      end
    end

    def self.update_by_direct_download
      CLI.report_notice 'Update from PACKMAN repository package.'
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

    def self.update_by_using_ftp
      if not PACKMAN.does_command_exist? 'git'
        PACKMAN.report_error "There is no #{PACKMAN.red 'git'}!"
      end
      ftp_mirror = ConfigManager.use_ftp_mirror
      CLI.report_notice "Update from PACKMAN FTP mirror #{CLI.green ftp_mirror}."
      if Dir.exist? '.git'
        local_git_sha1 = `git rev-parse HEAD`
        # Check if there is any modification.
        changes = `git status -s`
        if not changes.empty?
          CLI.report_error "You have local changes, which are not allowed when update from FTP mirror!"
        end
      else
        local_version = File.open('.version', 'r').read
      end
      PACKMAN.mkdir '.tmp', :silent
      PACKMAN.work_in '.tmp' do
        CLI.report_notice "Download #{CLI.green 'packman.tar.gz'} from #{ftp_mirror}."
        PACKMAN.download '.', "#{ftp_mirror}/packman.tar.gz", "packman.tar.gz"
        PACKMAN.decompress 'packman.tar.gz', :silent
        PACKMAN.work_in 'packman' do
          if Dir.exist? '.git'
            mirror_git_sha1 = `git rev-parse HEAD`
            if local_git_sha1 != mirror_git_sha1
              CLI.report_notice "Local version is different from mirror version, update local one."
              PACKMAN.cp '.', ENV['PACKMAN_ROOT']
            else
              CLI.report_notice "Everything is up-to-date."
            end
          else
            mirror_version = File.open('.version', 'r').read
          end
        end
      end
      PACKMAN.rm '.tmp'
    end
  end
end
