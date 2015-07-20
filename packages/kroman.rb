class Kroman < PACKMAN::Package
  url "https://github.com/cheunghy/kroman/archive/\
fafae2ac45ddba85871d24eeeb117b9613a93f3f.tar.gz"
  sha1 "a1f1cac4d80d676e3b032f3d8c0e11708bdb08d2"
  version '1.0'

  def install
    PACKMAN.run "make install PREFIX=#{prefix}"
  end
end
