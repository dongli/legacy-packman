class Grads < PACKMAN::Package
  label :compiler_insensitive
  label :external_binary

  attach 'data' do
    url 'ftp://cola.gmu.edu/grads/data2.tar.gz'
    sha1 'e1cd5f9c4fe8d6ed344a29ee00413aeb6323b7cd'
    decompress_option :put_into_directory => 'lib/grads'
  end

  binary do
    compiled_on :Mac, '>= 10.7'
    url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a3-bin-darwin11.4.tar.gz'
    sha1 'f10e086bc9ffcd5d229eb9c3edce2a8a532025d7'
    version '2.1.a3'
    decompress_option :strip_top_directories => 1
  end

  binary do
    compiled_on :RHEL, '>= 5.11'
    url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a3-bin-CentOS5.11-x86_64.tar.gz'
    sha1 'a7a9474f2907c556b52282a8d8c6e58e22ab7ae4'
    version '2.1.a3'
    decompress_option :strip_top_directories => 1
  end

  binary do
    compiled_on :CentOS, '>= 5.11'
    url 'ftp://cola.gmu.edu/grads/2.1/grads-2.1.a3-bin-CentOS5.11-x86_64.tar.gz'
    sha1 'a7a9474f2907c556b52282a8d8c6e58e22ab7ae4'
    version '2.1.a3'
    decompress_option :strip_top_directories => 1
  end

  def post_install
    PACKMAN.report_warning "You need to set #{PACKMAN.blue 'GADDIR'} environment variable to #{PACKMAN.install_root}/packman.active/lib/grads. #{PACKMAN.red "DON'T FORGET!"}"
  end
end
