class Vim < PACKMAN::Package
  url 'ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2'
  sha1 '601abf7cc2b5ab186f40d8790e542f86afca86b7'
  version '7.4'

  label 'compiler_insensitive'

  patch :embed

  depends_on 'ncurses'

  def install
    args = %W[
      --prefix=#{prefix}
      --enable-multibyte
      --enable-gui=no
      --enable-cscope
      --without-x
      --with-tlib=ncurses
      --with-features=huge
      --with-compiledby=PACKMAN
    ]
    %W[perl python ruby].each do |language|
      args << "--enable-#{language}interp"
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run "make install prefix=#{prefix} STRIP=true"
  end
end

__END__
diff -rupN vim74.old/src/os_unix.c vim74.new/src/os_unix.c
--- vim74.old/src/os_unix.c 2015-04-07 11:04:40.000000000 +0800
+++ vim74.new/src/os_unix.c 2015-04-07 11:07:25.000000000 +0800
@@ -827,7 +827,7 @@ init_signal_stack()
    || MAC_OS_X_VERSION_MAX_ALLOWED <= 1040)
  /* missing prototype.  Adding it to osdef?.h.in doesn't work, because
   * "struct sigaltstack" needs to be declared. */
- extern int sigaltstack __ARGS((const struct sigaltstack *ss, struct sigaltstack *oss));
+ extern int sigaltstack __ARGS((const stack_t *restrict ss, stack_t *restrict oss));
 #  endif
 
 #  ifdef HAVE_SS_BASE