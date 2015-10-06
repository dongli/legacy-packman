class Ncl < PACKMAN::Package
  label :compiler_insensitive
  label :external_binary

  binary :on => [ :Debian, :Ubuntu ], :version => [ '=~ 6.0', '>= 12.04' ] do
    if PACKMAN.os.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e088d94c-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '32b0c6192992910e26f7fd19b04e05a7d97fed10'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_Debian6.0_x86_64_gcc445.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0894e7d-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '662d22d0f915c6b2378dea902a8f9acfd1dee761'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_Debian6.0_i686_gcc445.tar.gz'
    end
  end

  binary :on => :Debian, :version => '=~ 7.8' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e087c7da-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'c0cbc8f6a813489e04fb91aa79a593bf0b614540'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_Debian7.8_x86_64_gcc472.tar.gz'
  end

  binary :on => :Mac, :version => '=~ 10.10' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e085cc06-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'b4b5ff0a760ef54c62720f1e4340227eea9a795d'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.10_64bit_gcc492.tar.gz'
  end

  binary :on => :Mac, :version => '=~ 10.9' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0849384-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '431758706a90bb28ffa068df6c73e5402ea7c031'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.9_64bit_gcc492.tar.gz'
  end

  binary :on => :Mac, :version => '=~ 10.8' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0852fc5-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '3528629ecc6930a6bb4bcdfe12e825ef08723db3'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.MacOS_10.8_64bit_gcc471.tar.gz'
  end

  binary :on => :RHEL, :version => '=~ 5.11' do
    if PACKMAN.os.x86_64?
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0883d0b-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '379b2f31b4e5fd588c8e118b03a74bd284bccdb2'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_RHEL5.11_x86_64_gcc412.tar.gz'
    else
      url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e08a11ce-cd9a-11e4-bb80-00c0f03d5b7c'
      sha1 '74baba69aa0a03861093fe5d6305fad09623552d'
      version '6.3.0'
      filename 'ncl_ncarg-6.3.0.Linux_RHEL5.11_i686_gcc412.tar.gz'
    end
  end

  binary :on => [ :RHEL, :Fedora, :CentOS ], :version => [ '=~ 6.4', '>= 14', '>= 6' ] do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e0866847-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 'c33f853e29867c4c234ae66928e7e34782d4ad1c'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_RHEL6.4_x86_64_gcc472.tar.gz'
  end

  binary :on => :CentOS, :version => '7' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e083a923-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '034f9df8d34553fd309fbdaec878cebf6bbc9d8b'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.Linux_CentOS7.0_x86_64_gcc482.tar.gz'
  end

  binary :on => :Cygwin, :version => '6.1' do
    url 'https://www.earthsystemgrid.org/download/fileDownload.htm?logicalFileId=e08a86ff-cd9a-11e4-bb80-00c0f03d5b7c'
    sha1 '1fc92ef0b47c77d07b9ce6f51fbb75e0039bed40'
    version '6.3.0'
    filename 'ncl_ncarg-6.3.0.CYGWIN_NT-6.1-WOW64_i686.tar.gz'
  end

  def post_install
    PACKMAN.replace bashrc, {
      /NCL_ROOT/ => 'NCARG_ROOT'
    }
  end
end
