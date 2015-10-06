class Ncurses < PACKMAN::Package
  url 'http://ftpmirror.gnu.org/ncurses/ncurses-5.9.tar.gz'
  sha1 '3e042e5f2c7223bffdaac9646a533b8c758b65b5'
  version '5.9'

  label :skipped if PACKMAN.mac?

  def system_prefix; '/usr'; end if PACKMAN.mac?

  # patch :embed

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
    ]
    args << '--without-ada' if PACKMAN.compiler(:c).vendor == :intel
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end

  def installed?
    if PACKMAN.mac?
      return File.exist? '/usr/include/ncurses.h'
    end
  end

  def install_method
    if PACKMAN.mac?
      return 'Sorry, Mac should come with Ncurses...'
    end
  end
end

__END__
diff --git a/Ada95/configure b/Ada95/configure
index 4db6f1f..e82bb4b 100755
--- a/Ada95/configure
+++ b/Ada95/configure
@@ -7460,7 +7460,6 @@ CF_EOF
 		chmod +x mk_shared_lib.sh
 		;;
 	darwin*) #(vi
-		EXTRA_CFLAGS="-no-cpp-precomp"
 		CC_SHARED_OPTS="-dynamic"
 		MK_SHARED_LIB='${CC} ${CFLAGS} -dynamiclib -install_name ${libdir}/`basename $@` -compatibility_version ${ABI_VERSION} -current_version ${ABI_VERSION} -o $@'
 		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=abi
diff --git a/configure b/configure
index 639b790..25d69b3 100755
--- a/configure
+++ b/configure
@@ -5584,7 +5584,6 @@ CF_EOF
 		chmod +x mk_shared_lib.sh
 		;;
 	darwin*) #(vi
-		EXTRA_CFLAGS="-no-cpp-precomp"
 		CC_SHARED_OPTS="-dynamic"
 		MK_SHARED_LIB='${CC} ${CFLAGS} -dynamiclib -install_name ${libdir}/`basename $@` -compatibility_version ${ABI_VERSION} -current_version ${ABI_VERSION} -o $@'
 		test "$cf_cv_shlib_version" = auto && cf_cv_shlib_version=abi
