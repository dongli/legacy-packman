class Sqlite < PACKMAN::Package
	url 'https://sqlite.org/2015/sqlite-autoconf-3080802.tar.gz'
  sha1 '1db237523419af7110e1d92c6b766e965f9322e4'
  version '3.8.8.2'

  label 'compiler_insensitive'
  label 'do_not_set_ld_library_path'

  depends_on 'readline'
  depends_on 'icu4c'

  attach 'extension_functions' do
    url 'https://www.sqlite.org/contrib/download/extension-functions.c/download/extension-functions.c?get=25'
    sha1 'c68fa706d6d9ff98608044c00212473f9c14892f'
  end

  attach 'sqlite_doc' do
    url 'https://sqlite.org/2015/sqlite-doc-3080802.zip'
    sha1 'a11a6ea95d3d4a88b8d7d4e0cb6fcc3e5f4bf887'
  end

  def install
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_ENABLE_RTREE'
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_ENABLE_FTS3 -DSQLITE_ENABLE_FTS3_PARENTHESIS'
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_ENABLE_COLUMN_METADATA'
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_SECURE_DELETE'
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_ENABLE_UNLOCK_NOTIFY'
    PACKMAN.append_env 'LDFLAGS', `#{Icu4c.bin}/icu-config --ldflags`.tr("\n", ' ')
    PACKMAN.append_env 'CPPFLAGS', `#{Icu4c.bin}/icu-config --cppflags`.tr("\n", ' ')
    PACKMAN.append_env 'CPPFLAGS', '-DSQLITE_ENABLE_ICU'
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-dynamic-extensions
      LIBS=#{PACKMAN.compiler('c').flag(:cxxlib)}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
    args = %W[
      -fno-common
      $CFLAGS
      #{extension_functions.package_path}
      -o libsqlitefunctions.#{PACKMAN.shared_library_suffix}
      #{ENV['CFLAGS']}
      -I.
      -lm
    ]
    # TODO: Figure out how to do this elegantly.
    if PACKMAN.mac?
      args << '-dynamiclib'
    elsif PACKMAN.linux?
      args << '-shared'
    end
    PACKMAN.run PACKMAN.compiler('c').command, *args
    PACKMAN.mv "libsqlitefunctions.#{PACKMAN.shared_library_suffix}", lib
    PACKMAN.mkdir doc, :silent
    PACKMAN.work_in doc do
      PACKMAN.decompress sqlite_doc.package_path
      PACKMAN.mv doc+"/#{File.basename sqlite_doc.filename, '.zip'}/*", doc
    end
  end
end
