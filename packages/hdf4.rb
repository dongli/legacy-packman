class Hdf4 < PACKMAN::Package
  url 'http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.bz2'
  sha1 '5163543895728dabb536a0659b3d965d55bccf74'
  version '4.2.10'

  depends_on 'zlib'
  depends_on 'szip'
  depends_on 'jpeg'

  patch :embeded

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DHDF4_BUILD_TOOLS=ON
      -DHDF4_BUILD_UTILS=ON
      -DHDF4_BUILD_WITH_INSTALL_NAME=ON
      -DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON
      -DHDF4_ENABLE_NETCDF=OFF
      -DHDF4_ENABLE_SZIP_SUPPORT=ON
      -DHDF4_ENABLE_Z_LIB_SUPPORT=ON
      -DHDF4_BUILD_FORTRAN=ON
      -DCMAKE_Fortran_MODULE_DIRECTORY=#{PACKMAN::Package.prefix(self)}/include
      -DJPEG_DIR=#{PACKMAN::Package.prefix(Jpeg)}/lib/cmake
      -DZLIB_DIR=#{PACKMAN::Package.prefix(Zlib)}/lib/cmake
      -DSZIP_DIR=#{PACKMAN::Package.prefix(Szip)}/lib/cmake
    ]
    args += PACKMAN::Package.default_cmake_args(self)
    PACKMAN.mkdir 'build', :force do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run 'make install'
    end
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index ba2cf13..27a3df4 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -95,7 +95,7 @@ MARK_AS_ADVANCED (HDF4_NO_PACKAGES)
 # Set the core names of all the libraries
 #-----------------------------------------------------------------------------
 SET (HDF4_LIB_CORENAME              "hdf4")
-SET (HDF4_SRC_LIB_CORENAME          "hdf")
+SET (HDF4_SRC_LIB_CORENAME          "df")
 SET (HDF4_SRC_FCSTUB_LIB_CORENAME   "hdf_fcstub")
 SET (HDF4_SRC_FORTRAN_LIB_CORENAME  "hdf_fortran")
 SET (HDF4_MF_LIB_CORENAME           "mfhdf")
