class Shapelib < PACKMAN::Package
  url 'http://download.osgeo.org/shapelib/shapelib-1.3.0.tar.gz'
  sha1 '599fde6f69424fa55da281506b297f3976585b85'
  version '1.3.0'

  def install
    PACKMAN.replace 'Makefile', {
      /^PREFIX\s*=.*$/ => "PREFIX = #{PACKMAN.prefix self}",
      /^#CC\s*=.*$/ => "CC = #{PACKMAN.compiler_command 'c'}"
    }
    PACKMAN.run 'make'
    PACKMAN.run 'make test' if not skip_test?
    PACKMAN.mkdir "#{PACKMAN.prefix self}/lib", :silent
    PACKMAN.mkdir "#{PACKMAN.prefix self}/include", :silent
    PACKMAN.mkdir "#{PACKMAN.prefix self}/bin", :silent
    PACKMAN.run 'make install'
  end
end
