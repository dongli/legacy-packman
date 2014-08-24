class Libpciaccess < PACKMAN::Package
  git 'http://anongit.freedesktop.org/git/xorg/lib/libpciaccess.git'
  tag 'libpciaccess-0.13.2'
  dirname 'libpciaccess-0.13.2'
  sha1 '898243fda1143dd379dfaf9e92707f1982a942ea'
  version '0.13.2'

  depends_on 'xorg_macros'

  skip_on :Mac_OS_X

  def install
    PACKMAN.replace 'autogen.sh', {
      /^(autoreconf) (-v --install \|\| exit 1)/ =>
        "\\1 -I#{PACKMAN::Package.prefix(Xorg_macros)}/share/aclocal \\2"
    }
    PACKMAN.replace 'src/common_interface.c', {
      /^(#else\n\n#include <sys\/endian.h>)$/ =>
        "#elif defined(__APPLE__) /* Mac OS X */\n"+
        "#include <machine/endian.h>\n"+
        "#define  LETOH_16(x) OSSwapLittleToHostInt16(x)\n"+
        "#define  HTOLE_16(x) OSSwapHostToLittleInt16(x)\n"+
        "#define  LETOH_32(x) OSSwapLittleToHostInt32(x)\n"+
        "#define  HTOLE_32(x) OSSwapHostToLittleInt32(x)\n\n\\1"
    }
    PACKMAN.run './autogen.sh'
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end