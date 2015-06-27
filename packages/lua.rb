class Lua < PACKMAN::Package
  url 'http://www.lua.org/ftp/lua-5.2.3.tar.gz'
  sha1 '926b7907bc8d274e063d42804666b40a3f3c124c'
  version '5.2.3'

  label :compiler_insensitive

  def install
    PACKMAN.replace 'src/Makefile', {
      /^\s*CC\s*=.*$/ => "CC= #{PACKMAN.compiler('c').command}"
    }
    PACKMAN.replace 'src/luaconf.h', {
      /#define LUA_ROOT.*/ => "#define LUA_ROOT \"#{prefix}\""
    }
    if PACKMAN.linux?
      platform = 'linux'
    elsif PACKMAN.mac?
      platform = 'macosx'
    elsif PACKMAN.cygwin?
      platform = 'generic'
    end
    PACKMAN.run "make #{platform} INSTALL_TOP=#{prefix} INSTALL_MAN=#{man}/man1"
    PACKMAN.run "make install INSTALL_TOP=#{prefix} INSTALL_MAN=#{man}/man1"
    PACKMAN.mkdir lib+'/pkgconfig'
    File.open(lib+'/pkgconfig/lua.pc', 'w') do |file|
      file << <<-EOT.keep_indent
        V= 5.2
        R= 5.2.3
        prefix=#{prefix}
        INSTALL_BIN= ${prefix}/bin
        INSTALL_INC= ${prefix}/include
        INSTALL_LIB= ${prefix}/lib
        INSTALL_MAN= ${prefix}/share/man/man1
        INSTALL_LMOD= ${prefix}/share/lua/${V}
        INSTALL_CMOD= ${prefix}/lib/lua/${V}
        exec_prefix=${prefix}
        libdir=${exec_prefix}/lib
        includedir=${prefix}/include

        Name: Lua
        Description: An Extensible Extension Language
        Version: 5.2.3
        Requires:
        Libs: -L${libdir} -llua -lm
        Cflags: -I${includedir}
      EOT
    end
  end
end