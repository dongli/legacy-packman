class Libdrm < PACKMAN::Package
  git 'http://anongit.freedesktop.org/git/mesa/drm.git'
  tag 'libdrm-2.4.56'
  dirname 'libdrm-2.4.56'
  sha1 '4f89a7caad342754dbbd84bfe0c5fec76a7bf604'
  version '2.4.56'

  depends_on 'pthread_stubs'
  # depends_on 'libpciaccess'

  skip_on :Mac_OS_X

  def install
    PACKMAN.replace 'configure.ac', {
      /^(AC_CHECK_FUNCS\(\[clock_gettime\], \[CLOCK_LIB=\],)$/ =>
         "case \"\$host_os\" in\n"+
         "darwin*|mingw*)\n"+
         "    ;;\n"+
         "*)\n"+
         "\\1",
      /^(AC_SUBST\(\[CLOCK_LIB\]\))$/ =>
         "\\1\n"+
         "    ;;\n"+
         "esac\n"
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