class Harfbuzz < PACKMAN::Package
  url 'http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.38.tar.bz2'
  sha1 '00c24a228206a5646166630e02b542d7d3fb4544'
  version '0.9.38'

  depends_on :glib
  depends_on :cairo
  depends_on :icu4c
  depends_on :freetype

  def install
    PACKMAN.handle_unlinked Freetype if PACKMAN.mac?
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --with-icu=#{Icu4c.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end
