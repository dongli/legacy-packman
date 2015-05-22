class Scons < PACKMAN::Package
  url 'https://downloads.sourceforge.net/scons/scons-2.3.4.tar.gz'
  sha1 '8c55f8c15221c1b3536a041d46056ddd7fa2d23a'
  version '2.3.4'

  label :compiler_insensitive

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run 'python setup.py install', *args
  end
end