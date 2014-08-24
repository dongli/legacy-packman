class Pthread_stubs < PACKMAN::Package
  git 'http://anongit.freedesktop.org/git/xcb/pthread-stubs.git'
  tag '0.3'
  dirname 'pthread-stubs-0.3'
  sha1 '2bb704ef21d6ed04595d3816e67fb9fc1dacd380'
  version '0.3'

  def install
    PACKMAN.run './autogen.sh'
    args = %W[
      --prefix=#{PACKMAN::Package.prefix(self)}
      --disable-dependency-tracking
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
  end
end