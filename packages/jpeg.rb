class Jpeg < PACKMAN::Package
  url 'http://www.ijg.org/files/jpegsrc.v8d.tar.gz'
  sha1 'f080b2fffc7581f7d19b968092ba9ebc234556ff'
  version '8d'

  label 'do_not_set_ld_library_path' if PACKMAN.mac?

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'

    create_cmake_config 'JPEG', 'include', 'lib/libjpeg.a'
  end
end
