class Hyrax_olfs < PACKMAN::Package
  url 'http://www.opendap.org/pub/olfs/olfs-1.12.1-webapp.tgz'
  sha1 '8ff3636531418d02fec9a24b61ec17559df97dc8'
  version '1.12.1'

  belongs_to 'hyrax'

  depends_on 'tomcat'

  label 'compiler_insensitive'

  def install
    PACKMAN.mkdir prefix, :force
    PACKMAN.cp '.', prefix
    PACKMAN.cp "#{prefix}/opendap.war", "#{Tomcat.prefix}/webapps"
  end
end
