class Fish < PACKMAN::Package
  url 'http://fishshell.com/files/2.1.2/fish-2.1.2.tar.gz'
  sha1 'f7f8d8d26721833be3458b8113c74b747296ec0b'
  version '2.1.2'

  label 'compiler_insensitive'

  def install
    args = %W[
      --prefix=#{prefix}
    ]
    PACKMAN.run './configure', *args
    PACKMAN.run 'make install'
    PACKMAN.caveat <<-EOT.keep_indent
      Remember to add:
        #{bin}/fish
      to /etc/shells. You may run:
        chsh -s #{bin}/fish
      to make FISH your default shell.
    EOT
  end
end