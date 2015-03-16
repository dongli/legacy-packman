class Tomcat < PACKMAN::Package
  url 'http://mirrors.cnnic.cn/apache/tomcat/tomcat-7/v7.0.57/bin/apache-tomcat-7.0.57.tar.gz'
  sha1 '49ffffe9c2e534e66f81b3173cdbf7e305a75fe2'
  version '7.0.57'

  label 'compiler_insensitive'

  def install
    PACKMAN.rm 'bin/*.bat'
    # Setup users.
    PACKMAN.replace 'conf/tomcat-users.xml', {
      /<tomcat-users>.*<\/tomcat-users>/m => <<-EOT.keep_indent
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
    PACKMAN.mkdir prefix, :force
    PACKMAN.cp '.', prefix
    # Check if 8080 port is occupied, if so we should choose another one.
    PACKMAN.report_notice "Search an available port for #{PACKMAN.green Tomcat}."
    is_found_aval_port = false
    port = 8080
    while port <= 10000
      if not PACKMAN::NetworkManager.is_port_open? 'localhost', port
        is_found_aval_port = true
        break
      end
    end
    if not is_found_aval_port
      PACKMAN.report_error "Can not find an available port!"
    else
      PACKMAN.report_notice "Use port #{port}."
      PACKMAN.replace "#{prefix}/conf/server.xml", {
        '<Connector port="8080"' => "<Connector port=\"#{port}\""
      }
    end
  end
end
