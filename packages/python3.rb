class Python3 < PACKMAN::Package
  url 'https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz'
  sha1 'b7f832e6d84b406db4c854e3eb46411e6931bc98'
  version '3.5.1'

  label :compiler_insensitive

  depends_on :pkgconfig
  depends_on :readline
  depends_on :openssl
  depends_on :sqlite
  depends_on :gdbm
  depends_on :x11

  attach 'setuptools' do
    url 'https://pypi.python.org/packages/source/s/setuptools/setuptools-18.3.1.tar.gz'
    sha1 '0e673ff59b3259bc8af3260ca2b82b4ac7d8d390'
  end

  attach 'pip' do
    url 'https://pypi.python.org/packages/source/p/pip/pip-7.1.2.tar.gz'
    sha1 '9eb9ea19b630412bc2b2b587fc6bbbee71950a96'
  end

  def site_packages
    v = PACKMAN::VersionSpec.new version
    "#{prefix}/lib/python#{v.major_minor}/site-packages"
  end

  def install
    ENV['PYTHONHOME'] = nil
    ENV['PYTHONPATH'] = nil
    PACKMAN.replace 'setup.py', {
      'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))' => 'pass',
      "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')" =>
        "do_readline = '#{Readline_.lib}/libhistory.#{PACKMAN.shared_library_suffix}'"
    }
    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
    ]
    if PACKMAN.mac?
      args << "--enable-framework=#{frameworks}"
      args << "MACOSX_DEPLOYMENT_TARGET=#{PACKMAN.os.version.major_minor}"
    end
    args << "--without-gcc" if PACKMAN.compiler(:c).vendor != :gnu
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run "make install PYTHONAPPSDIR=#{prefix}"
    #PACKMAN.run 'make quicktest' if not skip_test?
    # Install setuptools and pip.
    PACKMAN.append_env 'PYTHONPATH', site_packages, ':'
    PACKMAN.mkdir site_packages, :skip_if_exist
    [setuptools, pip].each do |x|
      PACKMAN.decompress x.package_path
      PACKMAN.work_in File.basename(x.filename, '.tar.gz') do
        PACKMAN.run "#{bin}/python3 -s setup.py --no-user-cfg install --force --verbose --install-scripts=#{bin} --install-lib=#{site_packages}"
      end
    end
  end

  def post_install
    PACKMAN.report_warning "You may need to set #{PACKMAN.blue 'PYTHONPATH'} environment variable to #{site_packages}."
  end
end
