class Bzip2 < PACKMAN::Package
  url 'http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz'
  sha1 '3f89f861209ce81a6bab1fd1998c0ef311712002'
  version '1.0.6'

  def install
    PACKMAN.run "make install PREFIX=#{prefix}"
    PACKMAN.mkdir share
    PACKMAN.mv "#{prefix}/man", share
  end
end