class Python3 < PACKMAN::Package
  url 'https://www.python.org/ftp/python/3.4.3/Python-3.4.3.tar.xz'
  sha1 '7ca5cd664598bea96eec105aa6453223bb6b4456'
  version '3.4.3'

  label 'compiler_insensitive'

  depends_on 'pkgconfig'
  depends_on 'readline'
  depends_on 'openssl'
  depends_on 'sqlite'
  depends_on 'gdbm'
  depends_on 'x11'

  attach 'setuptools' do
    url 'https://pypi.python.org/packages/source/s/setuptools/setuptools-12.3.tar.gz'
    sha1 '1c43b290e8de50e4f1e1074e179289dc9cddfbf2'
  end

  attach 'pip' do
    url 'https://pypi.python.org/packages/source/p/pip/pip-6.0.8.tar.gz'
    sha1 'bd59a468f21b3882a6c9d3e189d40c7ba1e1b9bd'
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
        "do_readline = '#{Readline.lib}/libhistory.#{PACKMAN::OS.shared_library_suffix}'"
    }
    args = %W[
      --prefix=#{prefix}
      --enable-ipv6
      --datarootdir=#{share}
      --datadir=#{share}
    ]
    if PACKMAN::OS.mac_gang?
      args << "--enable-framework=#{frameworks}"
      args << "MACOSX_DEPLOYMENT_TARGET=#{PACKMAN::OS.version.major_minor}"
    end
    args << "--without-gcc" if PACKMAN.compiler_vendor('c') != 'gnu'
    PACKMAN.set_cppflags_and_ldflags [Sqlite, Gdbm]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run "make install PYTHONAPPSDIR=#{prefix}"
    PACKMAN.run 'make quicktest' if not skip_test?
    # Install setuptools and pip.
    PACKMAN.append_env 'PYTHONPATH', site_packages, ':'
    [setuptools, pip].each do |x|
      PACKMAN.decompress x.package_path
      PACKMAN.work_in File.basename(x.filename, '.tar.gz') do
        PACKMAN.run "#{bin}/python3 -s setup.py --no-user-cfg install --force --verbose --install-scripts=#{bin} --install-lib=#{site_packages}"
      end
    end
  end

  def postfix
    PACKMAN.append bashrc, <<-EOT
      export PYTHONPATH="#{site_packages}:$PYTHONPATH"
    EOT
  end
end
