class Patchelf < PACKMAN::Package
  # This package is used for repairing dynamic links in Linux.
  # In Mac, we have 'install_name_tool'.
  url 'http://nixos.org/releases/patchelf/patchelf-0.8/patchelf-0.8.tar.bz2'
  sha1 'd0645e9cee6f8e583ae927311c7ce88d29f416fc'
  version '0.8'

  head do
    git 'https://github.com/NixOS/patchelf.git'
    sha1 '62e29b4b5f701fdb90f38bbc4604be763619d1d8'
    depends_on :autoconf
    depends_on :automake
  end

  label :compiler_insensitive
  label :skipped if PACKMAN.mac?

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
    ]
    if use_head?
      PACKMAN.run './bootstrap.sh'
      # Because I added rpath options, the no-rpath test fails.
      PACKMAN.replace 'tests/no-rpath.sh', {
        /(oldRPath=.*)$/ => "../src/patchelf --remove-rpath ${SCRATCH}/no-rpath\n\\1\n"
      }
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make'
    PACKMAN.run 'make check'
    PACKMAN.run 'make install'
  end
end
