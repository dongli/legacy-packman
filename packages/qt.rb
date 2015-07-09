class Qt < PACKMAN::Package
  url 'https://download.qt.io/official_releases/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz'
  sha1 '76aef40335c0701e5be7bb3a9101df5d22fe3666'
  version '4.8.7'

  def install
    args = %W[
      -prefix #{prefix}
      -qt-libtiff
      -qt-libpng
      -qt-libjpeg
      -confirm-license
      -opensource
      -nomake demos
      -nomake examples
      -no-qt3support
      -fast
      -release
    ]
    if PACKMAN.mac? and PACKMAN.compiler('c').vendor == 'llvm'
      args << '-platform'
      if PACKMAN.os.version >= '10.9'
        args << 'unsupported/macx-clang-libc++'
      else
        args << 'unsupported/macx-clang'
      end
    end
    if PACKMAN.os.x86_64?
      args << '-arch x86_64'
    else
      args << '-arch x86'
    end
    PACKMAN.run './configure', *args
    PACKMAN.run 'make -j2'
    PACKMAN.run 'make install'
  end
end
