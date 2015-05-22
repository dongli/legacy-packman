class Hyrax_olfs < PACKMAN::Package
  url 'http://www.opendap.org/pub/olfs/olfs-1.13.0-webapp.tgz'
  sha1 'a849d58ac49a15b97699700653d2498ee4219aee'
  version '1.13.0'

  belongs_to 'hyrax'

  depends_on 'tomcat'

  label :compiler_insensitive

  def install
    PACKMAN.mkdir prefix, :force
    PACKMAN.cp '.', prefix
    PACKMAN.cp "#{prefix}/opendap.war", "#{Tomcat.prefix}/webapps"
  end
end
