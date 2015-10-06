class Isl < PACKMAN::Package
  url 'http://isl.gforge.inria.fr/isl-0.14.1.tar.bz2'
  sha1 'b653327b20e807d1df3a7e2f546ea924f1e030c0'
  version '0.14.1'

  depends_on :gmp

  binary do
    compiled_on :Mac, '=~ 10.11'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 'aebe135c08241a734b00590677f77e0d526c0b3d'
    version '0.14.1'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --with-gmp-prefix=#{Gmp.prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
