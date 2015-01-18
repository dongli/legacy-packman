class Gadap < PACKMAN::Package
  url 'ftp://cola.gmu.edu/grads/Supplibs/2.1/src/gadap-2.0.tar.gz'
  sha1 'cbd72f39296ac2745350471293ffe407ac750c1d'
  version '2.0'

  depends_on 'opendap'

  def install
    # Fix bugs!
    PACKMAN.replace 'src/gaBaseTypes.h', /(#include "Url.h")/ => "\\1\nusing namespace libdap;\n"
    PACKMAN.replace 'src/gaConnect.h', /(#include <DAS.h>)/ => "\\1\nusing namespace libdap;\n"
    PACKMAN.replace 'src/gaReports.h', /(#include "gaUtils.h")/ => "\\1\nusing namespace libdap;\n"
    PACKMAN.replace 'src/gaUtils.h', /(#include "gadap.h")/ => "\\1\nusing namespace libdap;\n"
    PACKMAN.run "./configure --prefix=#{PACKMAN.prefix self}"
    PACKMAN.run 'make'
    PACKMAN.run 'make install'
  end
end
