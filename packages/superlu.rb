class Superlu < PACKMAN::Package
  url 'http://crd-legacy.lbl.gov/~xiaoye/SuperLU/superlu_5.1.tar.gz'
  sha1 '0a16ac58d6b33b209c0afa0e9ab6b0515b14f301'
  version '5.1'

  depends_on :lapack
  depends_on :openblas

  def install
    if PACKMAN.linux?
      PACKMAN.cp 'MAKE_INC/make.linux', 'make.inc'
    elsif PACKMAN.mac?
      PACKMAN.cp 'MAKE_INC/make.mac-x', 'make.inc'
    end
    if PACKMAN.compiler(:c).vendor == :llvm
      PACKMAN.replace 'make.inc', {
        '-fopenmp' => ''
      }
    end
    if PACKMAN.has_compiler? :fortran, :not_exit and PACKMAN.compiler(:fortran).vendor == :intel
      fortran_lib = '-lifcore'
    end
    args = %W[
      RANLIB=true
      CC="${CC}"
      CFLAGS="${CFLAGS}"
      SuperLUroot=#{FileUtils.pwd}
      SUPERLULIB=#{FileUtils.pwd}/lib/libsuperlu.a
      NOOPTS=-fPIC
      BLASDEF=-DUSE_VENDOR_BLAS
      BLASLIB='-L#{link_root}/lib -lopenblas -L#{Lapack.prefix} -lblas #{fortran_lib}'
    ]
    if PACKMAN.has_compiler? :fortran, :not_exit
      args << 'FORTRAN="${FC}" FFLAGS="${FCFLAGS}"'
    end
    PACKMAN.run 'make lib', *args
    PACKMAN.run 'make testing', *args
    PACKMAN.work_in 'TESTING' do
      PACKMAN.run 'make', *args
      %w[stest dtest ctest ztest].each do |test|
        PACKMAN.blue_arrow `tail -1 #{test}.out`.chomp
      end
    end
    PACKMAN.mkdir "#{inc}/superlu"
    PACKMAN.cp 'SRC/*.h', "#{inc}/superlu"
    PACKMAN.mkdir lib
    PACKMAN.cp 'lib/*', lib
  end

  def post_install
    File.chmod 0644, inc+'/superlu/superlu_enum_consts.h'
  end
end
