class Mongodb < PACKMAN::Package
  url 'https://fastdl.mongodb.org/src/mongodb-src-r3.0.4.tar.gz'
  sha1 '5df86eabb1631dfb3cd29a1424f7c65f70277e58'
  version '3.0.4'

  label :compiler_insensitive

  option 'use_boost' => false

  depends_on 'boost' if use_boost?
  depends_on 'openssl'
  depends_on 'scons'

  def install
    args = %W[
      --prefix=#{prefix}
      -j2
      --cc=#{PACKMAN.compiler('c').command}
      --cxx=#{PACKMAN.compiler('c++').command}
      --64
      --ssl
      --extrapath=#{Openssl.prefix}
    ]
    args << '--use-system-boost' if use_boost?
    PACKMAN.run 'scons install', *args
    PACKMAN.mkdir etc, :silent
    PACKMAN.mkdir "#{var}/mongodb", :silent
    PACKMAN.mkdir "#{var}/log/mongodb", :silent
    File.open("#{etc}/mongod.conf", 'w') do |file|
      file << <<-EOT.gsub(/^\s+/, '')
      systemLog:
        destination: file
        path: #{var}/log/mongodb/mongo.log
        logAppend: true
      storage:
        dbPath: #{var}/mongodb
      net:
        bindIp: 127.0.0.1
      EOT
    end
  end
end
