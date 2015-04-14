class Cmake < PACKMAN::Package
  url 'http://www.cmake.org/files/v3.2/cmake-3.2.1.tar.gz'
  sha1 '53c1fe2aaae3b2042c0fe5de177f73ef6f7b267f'
  version '3.2.1'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run "./bootstrap", *args
    PACKMAN.run "make"
    PACKMAN.run "make install"
  end

  def postfix
    modules = 'cmake-3.2/Modules'
    # Fix FindArmadillo.cmake.
    PACKMAN.replace "#{share}/#{modules}/FindArmadillo.cmake", {
      /(find_library\(ARMADILLO_LIBRARY\n\s*NAMES armadillo)/ => <<-EOT.keep_indent
        \\1\n
        HINTS
          ENV ARMADILLO_DIR
          ENV ARMADILLO_ROOT
        PATH_SUFFIXES
          lib
          lib64
      EOT
    }
    PACKMAN.replace "#{share}/#{modules}/FindArmadillo.cmake", {
      /(find_path\(ARMADILLO_INCLUDE_DIR\n\s*NAMES armadillo)/ => <<-EOT.keep_indent
        \\1\n
        HINTS
          ENV ARMADILLO_DIR
          ENV ARMADILLO_ROOT
        PATH_SUFFIXES
          include
      EOT
    }
    # Fix FindGDAL.cmake.
    PACKMAN.replace "#{share}/#{modules}/FindGDAL.cmake", {
      'set(GDAL_INCLUDE_DIRS ${GDAL_INCLUDE_DIR})' => <<-EOT.keep_indent
        exec_program(${GDAL_CONFIG} ARGS --dep-libs OUTPUT_VARIABLE GDAL_CONFIG_DEP_LIBS)
        set(GDAL_LIBRARIES ${GDAL_LIBRARY} ${GDAL_CONFIG_DEP_LIBS})
        set(GDAL_INCLUDE_DIRS ${GDAL_INCLUDE_DIR})
      EOT
    }
  end
end
