class Tomcat < PACKMAN::Package
  url 'http://mirror.bit.edu.cn/apache/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz'
  sha1 '21c16dfed30b4a15c129e4448e63834103c88272'
  version '7.0.56'

  devel do
    url 'http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v8.0.14/bin/apache-tomcat-8.0.14.tar.gz'
    sha1 '1a63a44dbf1b73f2256a2f21521b3d5ee3e8b5bf'
    version '8.0.14'
  end

  label 'compiler_insensitive'

  def install
    PACKMAN.rm 'bin/*.bat'
    # Setup users.
    PACKMAN.replace 'conf/tomcat-users.xml', {
      /<tomcat-users>.*<\/tomcat-users>/m => <<-EOT
<tomcat-users>
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <role rolename="manager"/>
  <role rolename="admin"/>
  <user username="tomcat" password="tomcat" roles="tomcat,admin,manager"/>
  <user username="both" password="tomcat" roles="tomcat,role1"/>
  <user username="role1" password="tomcat" roles="role1"/>
</tomcat-users>
      EOT
    }
    tomcat = PACKMAN.prefix(self)
    PACKMAN.mkdir tomcat, :force
    PACKMAN.cp '.', tomcat
    # Check if 8080 port is occupied, if so we should choose another one.
    PACKMAN::CLI.report_notice "Search an available port for #{PACKMAN::CLI.green Tomcat}."
    is_found_aval_port = false
    port = 8080
    while port <= 10000
      if not PACKMAN::NetworkManager.is_port_open? 'localhost', port
        is_found_aval_port = true
        break
      end
    end
    if not is_found_aval_port
      PACKMAN::CLI.report_error "Can not find an available port!"
    else
      PACKMAN::CLI.report_notice "Use port #{port}."
      PACKMAN.replace "#{tomcat}/conf/server.xml", {
        '<Connector port="8080"' => "<Connector port=\"#{port}\""
      }
    end
  end
end
