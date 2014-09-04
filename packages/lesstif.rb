class Lesstif < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/lesstif/lesstif/0.95.2/lesstif-0.95.2.tar.bz2'
  sha1 'b894e544d529a235a6a665d48ca94a465f44a4e5'
  version '0.95.2'

  depends_on 'x11'
  depends_on 'freetype'

  skip_on :Ubuntu

  def install
    PACKMAN.report_error "Under construction!"    
  end
end
