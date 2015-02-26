class Liblqr < PACKMAN::Package
  url 'http://liblqr.wdfiles.com/local--files/en:download-page/liblqr-1-0.4.2.tar.bz2'
  sha1 '69639f7dc56a084f59a3198f3a8d72e4a73ff927'
  version '0.4.2'

  depends_on 'glib'

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    PACKMAN.set_cppflags_and_ldflags [Glib]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
