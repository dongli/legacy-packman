class Perl < PACKMAN::Package
  url 'http://www.cpan.org/src/5.0/perl-5.20.1.tar.bz2'
  sha1 'cd424d1520ba2686fe5d4422565aaf880e9467f6'
  version '5.20.1'

  label :compiler_insensitive
  label :master_package

  depends_on :zlib

  def install
    # Avoid the linking with system Zlib that may not be compiled with '-fPIC'.
    PACKMAN.append_env 'BUILD_ZLIB', 'yes'
    PACKMAN.append_env 'ZLIB_INCLUDE', FileUtils.pwd+'/cpan/Compress-Raw-Zlib/zlib-src'
    PACKMAN.append_env 'ZLIB_LIB', FileUtils.pwd+'/cpan/Compress-Raw-Zlib/zlib-src'
    # Perl doesn't respect CFLAGS, so we need to hardcode '-fPIC' flag.
    args = %W[
      -des
      -Dprefix=#{prefix}
      -Dcc="#{PACKMAN.compiler(:c).command} -fPIC"
      -Dusethreads
      -Duselargefiles
    ]
    PACKMAN.run './Configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end
