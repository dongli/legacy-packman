class Vis5dx < PACKMAN::Package
  url 'http://kaz.dl.sourceforge.net/project/vis5d/vis5d/vis5d%2B-1.3.0-beta/vis5d%2B-1.3.0-beta.tar.gz'
  sha1 '0d944af10c8c3b729467e1540b0a2634058cedb1'
  filename 'vis5dx-1.3.0-beta.tar.gz'
  version '1.3.0'

  depends_on 'netcdf_c'
  depends_on 'mesa3d'

  def install
    # http://cypresslin.web.fc2.com/Memo/M-ENG-Vis5DInst.html
    PACKMAN.replace 'src/misc.h', {
      /^extern float round\( float x \);$/ => 'extern double round( double x );'
    }
    PACKMAN.replace 'src/misc.c', {
      /^float round\( float x \)$/ => 'double round( double x )'
    }
    PACKMAN.replace 'util/igmk3d.f', {
      /^(\s*DATA MISS\/'80808080'X\/\s*)$/ => "      INTEGER(KIND=8) MISS\n\\1"
    }
    PACKMAN.replace 'util/igg3d.f', {
      /^(\s*DATA NULL\/'80808080'X\/.*)$/ => "      INTEGER(KIND=8) NULL\n\\1",
      /^(\s*DATA ENDMRK\/'80808080'X\/.*)$/ => "      INTEGER(KIND=8) ENDMRK\n\\1"
    }
    PACKMAN.replace 'util/kludge.f', {
      /^\s*CALL IDATE\(MON,IDAY,IYEAR\)$/ =>
        "      INTEGER(Kind=4), dimension(3) :: DateArray\n"+
        "      INTEGER(Kind=4) :: MON,IDAY,IYEAR\n"+
        "      CALL IDATE(DateArray)\n"+
        "      MON=DateArray(1)\n"+
        "      IDAY=DateArray(2)\n"+
        "      IYEAR=DateArray(3)\n"
    }
    args = %W[
      --prefix=#{prefix}
      --with-netcdf=#{Netcdf_c.prefix}
    ]
    if PACKMAN.mac?
      args << 'CPPFLAGS="-I/usr/X11R6/include"'
      args << 'LDFLAGS="-L/usr/X11R6/lib"'
    end
    PACKMAN.run './configure', *args
    if PACKMAN.mac?
      PACKMAN.replace 'libtool', {
        /^allow_undefined_flag="(.*)"$/ => 'allow_undefined_flag="\1 -flat_namespace"'
      }
    end
    PACKMAN.run 'make all'
    PACKMAN.run 'make install'
  end
end
