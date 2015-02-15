class Proj < PACKMAN::Package
  url 'http://download.osgeo.org/proj/proj-4.8.0.tar.gz'
  sha1 '5c8d6769a791c390c873fef92134bf20bb20e82a'
  version '4.8.0'

  def install
    # To avoid the 'sign' function conflict with Hdf_eos2.
    PACKMAN.replace 'src/PJ_healpix.c', /sign\s*\(/ => 'sign_in_proj('
    # Fix the wrong file name, shame on Proj developers.
    PACKMAN.replace 'src/jniproj.c', 'org_proj4_PJ.h' => 'org_proj4_Projections.h'
    args = %W[
      --prefix=#{prefix}
      --enable-static=yes
      --enable-shared=yes
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make all'
    PACKMAN.run 'make install'
  end
end
