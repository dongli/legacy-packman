class Boost < PACKMAN::Package
  url 'https://downloads.sourceforge.net/project/boost/boost/1.60.0/boost_1_60_0.tar.bz2'
  sha1 '7f56ab507d3258610391b47fef6b11635861175a'
  version '1.60.0'

  # Toolsets supported by Boost:
  #   acc, como, darwin, gcc, intel-darwin, intel-linux, kcc, kylix,
  #   mipspro, mingw(msys), pathscale, pgi, qcc, sun, sunpro, tru64cxx, vacpp

  patch :embed

  option :use_cxx11 => true

  binary do
    compiled_on :Mac, '=~ 10.10'
    compiled_by :cxx => [ :gnu, '=~ 5.2' ]
    sha1 'c30efd5f5d0699f11b654410b0549f091eaf302a'
    version '1.57.0'
  end

  def install
    cxx_compiler = PACKMAN.compiler(:cxx).command
    compiler_flags = PACKMAN.compiler(:cxx).default_flags[:cxx]
    link_flags = ''
    toolset = PACKMAN.compiler(:cxx).vendor
    # Rename toolset according to Boost.Build rule.
    if toolset == :intel
      # Lower version (e.g. 11.1) has issues to compile Boost.
      if PACKMAN.compiler(:cxx).version <= '11.1'
        PACKMAN.report_error "Intel compiler is too old to compile Boost! See "+
          "https://software.intel.com/en-us/articles/boost-1400-compilation-error-while-building-with-intel-compiler/"
      end
      if PACKMAN.mac?
        toolset << '-darwin'
      elsif PACKMAN.linux?
        toolset << '-linux'
      end
    elsif toolset == :gnu
      if PACKMAN.mac?
        toolset = 'darwin'
      elsif PACKMAN.linux?
        toolset = 'gcc'
      end
    elsif toolset == :llvm
      toolset = 'clang'
    end
    compiler_flags << ' -std=c++11' if use_cxx11?
    link_flags << ' -stdlib=libc++' if PACKMAN.mac?
    open('user-config.jam', 'w') do |file|
      file << "using #{toolset} : : #{cxx_compiler} : <compilerflags>\"#{compiler_flags}\" <linkflags>\"#{link_flags}\""
    end
    args = %W[
      --prefix=#{prefix}
      --with-toolset=#{toolset}
    ]
    PACKMAN.run './bootstrap.sh', *args
    args = %W[
      --prefix=#{prefix}
      -q
      -d2
      -j2
      toolset=#{toolset}
      variant=release
      install
    ]
    # Check if python development files are installed.
    if not PACKMAN.os_installed? ['python-dev', 'python-devel']
      PACKMAN.report_warning 'Python development files are not installed, '+
        'so Boost will be installed without python library.'
      PACKMAN.report_warning "If you really need that library, cancel and "+
        "install #{PACKMAN.red 'python-dev'} or #{PACKMAN.red 'python-devel'}."
      args << '--without-python'
    end
    if PACKMAN.mac? and toolset =~ /clang/
      # Boost.Log cannot be built using Apple GCC at the moment. Disabled
      # on such systems.
      args << "--without-log"
    end
    PACKMAN.run './b2', *args
  end
end

__END__
diff -Nur boost_1_60_0/boost/graph/adjacency_matrix.hpp boost_1_60_0-patched/boost/graph/adjacency_matrix.hpp
--- boost_1_60_0/boost/graph/adjacency_matrix.hpp 2015-10-23 05:50:19.000000000 -0700
+++ boost_1_60_0-patched/boost/graph/adjacency_matrix.hpp 2016-01-19 14:03:29.000000000 -0800
@@ -443,7 +443,7 @@
     // graph type. Instead, use directedS, which also provides the
     // functionality required for a Bidirectional Graph (in_edges,
     // in_degree, etc.).
-    BOOST_STATIC_ASSERT(type_traits::ice_not<(is_same<Directed, bidirectionalS>::value)>::value);
+    BOOST_STATIC_ASSERT(!(is_same<Directed, bidirectionalS>::value));

     typedef typename mpl::if_<is_directed,
                                     bidirectional_tag, undirected_tag>::type
diff -Nur boost_1_60_0/boost/bimap/detail/debug/static_error.hpp boost_1_60_0-patched/boost/bimap/detail/debug/static_error.hpp
--- boost_1_60_0/boost/bimap/detail/debug/static_error.hpp  2015-01-26 03:41:57.000000000 +0800
+++ boost_1_60_0-patched/boost/bimap/detail/debug/static_error.hpp  2016-02-16 08:12:52.000000000 +0800
@@ -25,7 +25,6 @@
 // a static error.
 /*===========================================================================*/
 #define BOOST_BIMAP_STATIC_ERROR(MESSAGE,VARIABLES)                           \
-        struct BOOST_PP_CAT(BIMAP_STATIC_ERROR__,MESSAGE) {};                 \
         BOOST_MPL_ASSERT_MSG(false,                                           \
                              BOOST_PP_CAT(BIMAP_STATIC_ERROR__,MESSAGE),      \
                              VARIABLES)
