class Lesstif < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/lesstif/lesstif/0.95.2/lesstif-0.95.2.tar.bz2'
  sha1 'b894e544d529a235a6a665d48ca94a465f44a4e5'
  version '0.95.2'

  depends_on 'x11'
  depends_on 'freetype'

  def install
    PACKMAN.replace 'configure', {
      '`aclocal --print-ac-dir`' => "#{share}/aclocal"
    }
    PACKMAN.append_env 'LANG=C'
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --enable-production
      --disable-dependency-tracking
      --enable-shared
      --enable-static
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
  PACKMAN.clean_env
end
