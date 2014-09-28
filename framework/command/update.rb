module PACKMAN
  def self.update
    PACKMAN.cd ENV['PACKMAN_ROOT']
    if Dir.exist? '.git'
      update_by_using_git
    else
      update_by_direct_download
    end
    PACKMAN.cd_back
  end

  def self.update_by_using_git
    system 'git pull'
  end

  def self.update_by_direct_download
    # Read the current version tag.
    version_file = "#{ENV['PACKMAN_ROOT']}/.version"
    if not File.exist? version_file
      current_version = File.open(version_file, 'r').read
    else
      current_version = nil
      CLI.report_warning "#{CLI.red version_file} does not exist!"
    end
    url = 'https://api.github.com/repos/dongli/packman/tags'
    begin
      tags = eval `curl -s #{url}`.gsub(': ', ' => ')
      latest_version = tags.last['name']
      latest_tarball_url = tags.last['tarball_url']
    rescue
      CLI.report_error "Failed to retrieve information from #{url}!"
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
      PACKMAN.rm ENV['PACKMAN_ROOT']
      PACKMAN.mv dec_dir, ENV['PACKMAN_ROOT']
      PACKMAN.cd_back
      PACKMAN.rm tmp_dir
    else
      CLI.report_notice "PACKMAN #{CLI.blue current_version} is up-to-date."
    end
  end
end
