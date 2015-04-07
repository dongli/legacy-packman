class Vim < PACKMAN::Package
  url 'ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2'
  sha1 '601abf7cc2b5ab186f40d8790e542f86afca86b7'
  version '7.4'

  label 'compiler_insensitive'

  option 'use_vundle' => false

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
    if use_vundle?
      bundle_root = "#{ENV['HOME']}/.vim/bundle"
      vundle_root = "#{bundle_root}/Vundle.vim"
      vimrc = "#{ENV['HOME']}/.vimrc"
      PACKMAN.mkdir bundle_root, :skip_if_exist
      if not Dir.exist? vundle_root
        PACKMAN.git_clone bundle_root, 'https://github.com/gmarik/Vundle.vim', 'master'
      end
      FileUtils.touch(vimrc) if not File.exist? vimrc
      if not File.open(vimrc, 'r').read.match(/Added by PACKMAN/)
        PACKMAN.append vimrc, <<-EOT.keep_indent
          " ###################################################
          " Added by PACKMAN.
          set nocompatible
          filetype off
          set rtp+=~/.vim/bundle/Vundle.vim
          call vundle#begin()
          Plugin 'gmarik/Vundle.vim'
          " ---> Add you favorate vundle plugins here.
          call vundle#end()
          filetype plugin on
          set shortmess=c
          " ###################################################
        EOT
      end
    end
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
 diff -r 462a4499f9c6 runtime/doc/options.txt
--- a/runtime/doc/options.txt Fri Nov 29 14:24:42 2013 +0900
+++ b/runtime/doc/options.txt Fri Nov 29 18:07:09 2013 +0900
@@ -6259,6 +6259,9 @@
    A don't give the "ATTENTION" message when an existing swap file
    is found.
    I don't give the intro message when starting Vim |:intro|.
+   c don't give the |ins-completion-menu| message.  For example,
+   "-- XXX completion (YYY)", "match 1 of 2", "The only match",
+   "Pattern not found", "Back at original", etc.
 
  This gives you the opportunity to avoid that a change between buffers
  requires you to hit <Enter>, but still gives as useful a message as
diff -r 462a4499f9c6 src/edit.c
--- a/src/edit.c  Fri Nov 29 14:24:42 2013 +0900
+++ b/src/edit.c  Fri Nov 29 18:07:09 2013 +0900
@@ -3878,7 +3878,8 @@
      ins_compl_free();
      compl_started = FALSE;
      compl_matches = 0;
-     msg_clr_cmdline();    /* necessary for "noshowmode" */
+     if (!shortmess(SHM_COMPLETIONMENU))
+   msg_clr_cmdline();  /* necessary for "noshowmode" */
      ctrl_x_mode = 0;
      compl_enter_selects = FALSE;
      if (edit_submode != NULL)
@@ -5333,7 +5334,8 @@
      {
    ctrl_x_mode = 0;
    edit_submode = NULL;
-   msg_clr_cmdline();
+   if (!shortmess(SHM_COMPLETIONMENU))
+       msg_clr_cmdline();
    return FAIL;
      }
 
@@ -5594,12 +5596,12 @@
     showmode();
     if (edit_submode_extra != NULL)
     {
- if (!p_smd)
+ if (!p_smd && !shortmess(SHM_COMPLETIONMENU))
      msg_attr(edit_submode_extra,
        edit_submode_highl < HLF_COUNT
        ? hl_attr(edit_submode_highl) : 0);
     }
-    else
+    else if (!shortmess(SHM_COMPLETIONMENU))
  msg_clr_cmdline();  /* necessary for "noshowmode" */
 
     /* Show the popup menu, unless we got interrupted. */
diff -r 462a4499f9c6 src/option.h
--- a/src/option.h  Fri Nov 29 14:24:42 2013 +0900
+++ b/src/option.h  Fri Nov 29 18:07:09 2013 +0900
@@ -212,7 +212,8 @@
 #define SHM_SEARCH 's'   /* no search hit bottom messages */
 #define SHM_ATTENTION  'A'   /* no ATTENTION messages */
 #define SHM_INTRO  'I'   /* intro messages */
-#define SHM_ALL    "rmfixlnwaWtToOsAI" /* all possible flags for 'shm' */
+#define SHM_COMPLETIONMENU 'c' /* completion menu messages */
+#define SHM_ALL    "rmfixlnwaWtToOsAIc" /* all possible flags for 'shm' */
 
 /* characters for p_go: */
 #define GO_ASEL    'a'   /* autoselect */
diff -r 462a4499f9c6 src/screen.c
--- a/src/screen.c  Fri Nov 29 14:24:42 2013 +0900
+++ b/src/screen.c  Fri Nov 29 18:07:09 2013 +0900
@@ -9704,7 +9704,8 @@
      }
 #endif
 #ifdef FEAT_INS_EXPAND
-     if (edit_submode != NULL)   /* CTRL-X in Insert mode */
+     /* CTRL-X in Insert mode */
+     if (edit_submode != NULL && !shortmess(SHM_COMPLETIONMENU))
      {
    /* These messages can get long, avoid a wrap in a narrow
     * window.  Prefer showing edit_submode_extra. */