class Perl < PACKMAN::Package
  url 'http://www.cpan.org/src/5.0/perl-5.20.1.tar.bz2'
  sha1 'cd424d1520ba2686fe5d4422565aaf880e9467f6'
  version '5.20.1'

  label :compiler_insensitive
  label :master_package

  depends_on 'zlib'

  def install
    PACKMAN.append_env 'BUILD_ZLIB', 'no'
    PACKMAN.append_env 'ZLIB_INCLUDE', Zlib.include
    PACKMAN.append_env 'ZLIB_LIB', Zlib.lib
    # Perl doesn't respect CFLAGS, so we need to hardcode '-fPIC' flag.
    args = %W[
      -des
      -Dprefix=#{prefix}
      -Dcc="#{PACKMAN.compiler('c').command} -fPIC"
      -Dusethreads
      -Duselargefiles
    ]
    PACKMAN.run './Configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.run 'make install'
  end
end
