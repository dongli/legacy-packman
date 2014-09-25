class Openblas < PACKMAN::Package
  url 'https://github.com/xianyi/OpenBLAS/archive/v0.2.11.zip'
  sha1 '533526327ec9a375387de0c18d5d7f5ea60e299b'
  version '0.2.11'

  def install
    PACKMAN.run 'make'
    PACKMAN.run "make install PREFIX=#{PACKMAN::Package.prefix(self)}"
  end
end