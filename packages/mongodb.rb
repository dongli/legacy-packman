class Mongodb < PACKMAN::Package
  url 'https://fastdl.mongodb.org/src/mongodb-src-r2.6.7.tar.gz'
  sha1 'c11c9d31063f2fc126249f7580e8417a8f4ef2b5'
  version '2.6.7'

  label 'compiler_insensitive'

  option 'use_boost' => false

  depends_on 'boost' if use_boost?
  depends_on 'openssl'
  depends_on 'scons'

  def install
    if PACKMAN.mac?
      PACKMAN.replace 'SConstruct', {
        "osx_version_choices = ['10.6', '10.7', '10.8', '10.9']" =>
        "osx_version_choices = ['10.6', '10.7', '10.8', '10.9', '10.10']"
      }
    end
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