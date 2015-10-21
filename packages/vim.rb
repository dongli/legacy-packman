class Vim < PACKMAN::Package
  url 'ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2'
  sha1 '601abf7cc2b5ab186f40d8790e542f86afca86b7'
  version '7.4'

  label :compiler_insensitive

  option :use_vundle => false
  option :with_perl => false
  option :with_ruby => false
  option :with_python => false
  option :with_lua => true

  patch :embed

  depends_on :ncurses
  depends_on :perl if with_perl?
  depends_on :ruby if with_ruby?
  depends_on :python if with_python?
  depends_on :lua if with_lua?

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :c => [ :llvm, '=~ 7.0' ]
    sha1 'd1b70ac5984d8fcdef788c63e4c4fb7cecb70aac'
    version '7.4'
  end

  def install
    PACKMAN.append_env 'LUA_PREFIX', Lua.prefix
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
    %w[perl ruby python lua].each do |language|
      if eval "with_#{language}?"
        args << "--enable-#{language}interp"
      else
        args << "--disable-#{language}interp"
      end
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run "make install prefix=#{prefix} STRIP=true"
    PACKMAN.report_notice "Link #{PACKMAN.blue 'vim'} into #{PACKMAN::blue 'vi'}."
    PACKMAN.work_in bin do
      PACKMAN.ln 'vim', 'vi'
    end
  end

  def post_install
    if use_vundle?
      bundle_root = "#{ENV['HOME']}/.vim/bundle"
      vundle_root = "#{bundle_root}/Vundle.vim"
      vimrc = "#{ENV['HOME']}/.vimrc"
      PACKMAN.mkdir bundle_root, :skip_if_exist
      if not Dir.exist? vundle_root
        PACKMAN.git_clone bundle_root, 'https://github.com/gmarik/Vundle.vim'
      end
      FileUtils.touch(vimrc) if not File.exist? vimrc
      if not File.open(vimrc, 'r').read.match(/Added by PACKMAN/)
        PACKMAN.append vimrc, <<-EOT.keep_indent
          " ###################################################
          " Added by PACKMAN.
          " Good defaults.
          set smarttab
          set expandtab
          set autoindent
          set smartindent
          set backspace=indent,eol,start
          set hlsearch
          set number
          syntax on
          filetype plugin indent on
          " Jump to last edit location.
          autocmd BufReadPost * if line("'\\"") > 1 && line("'\\"") <= line("$") | exe "normal! g'\\"" | endif
          " Status bar.
          set laststatus=2
          set statusline=%F%m\\ [type=%Y]\\ [line=%l,column=%c,%p%%]
          " Vundle settings.
          set nocompatible
          filetype off
          set rtp+=~/.vim/bundle/Vundle.vim
          call vundle#begin()
          Plugin 'gmarik/Vundle.vim'
          " ---> Add you favorate vundle plugins here.
          "Plugin 'Shougo/neocomplete.vim'
          "Plugin 'Shougo/neosnippet.vim'
          "Plugin 'Shougo/neosnippet-snippets'
          call vundle#end()
          filetype plugin on
          let g:neocomplete#enable_at_startup = 1
          let g:neocomplete#enable_smart_case = 1
          imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \\ "\\<Plug>(neosnippet_expand_or_jump)"
            \\: pumvisible() ? "\\<C-n>" : "\\<TAB>"
          smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \\ "\\<Plug>(neosnippet_expand_or_jump)"
            \\: "\\<TAB>"
          " ###################################################
        EOT
      end
    end
  end
end

__END__
diff --git a/src/os_unix.h b/src/os_unix.h
index 02eeafc..57c45c9 100644
--- a/src/os_unix.h
+++ b/src/os_unix.h
@@ -37,6 +37,10 @@
 # define HAVE_TOTAL_MEM
 #endif

+#if defined(__APPLE__)
+#include <AvailabilityMacros.h>
+#endif
+
 #if defined(__CYGWIN__) || defined(__CYGWIN32__)
 # define WIN32UNIX /* Compiling for Win32 using Unix files. */
 # define BINARY_FILE_IO
