class Mlpack < PACKMAN::Package
  url 'http://www.mlpack.org/files/mlpack-2.0.1.tar.gz'
  sha1 '27df05cff83d202f5d64a3d3fa4bdc4d9a6bc4be'
  version '2.0.1'

  depends_on :cmake
  depends_on :armadillo
  depends_on :boost
  depends_on :libxml2

  option :use_cxx11 => true

  patch :embed

  def install
    # Note: DBoost_NO_BOOST_CMAKE is set to ON to let CMake do the dirty job.
    args = %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_BUILD_TYPE='Release'
      -DARMADILLO_INCLUDE_DIR=#{link_root}/include
      -DARMADILLO_LIBRARY=#{link_root}/lib/libarmadillo.#{PACKMAN.shared_library_suffix}
      -DBoost_NO_BOOST_CMAKE=ON
    ]
    args << "-DCMAKE_CXX_FLAGS='-std=c++11'" if use_cxx11?
    PACKMAN.mkdir 'build', :force, :silent do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run 'make -j2'
      PACKMAN.run 'make test' if not skip_test?
      PACKMAN.run 'make install'
    end
  end
end

__END__
diff -Nur mlpack-2.0.1/src/mlpack/methods/kmeans/kmeans_impl.hpp mlpack-2.0.1-patched/src/mlpack/methods/kmeans/kmeans_impl.hpp
--- mlpack-2.0.1/src/mlpack/methods/kmeans/kmeans_impl.hpp  2016-02-05 06:40:47.000000000 +0800
+++ mlpack-2.0.1-patched/src/mlpack/methods/kmeans/kmeans_impl.hpp  2016-02-17 10:51:05.000000000 +0800
@@ -175,7 +175,7 @@
     iteration++;
     Log::Info << "KMeans::Cluster(): iteration " << iteration << ", residual "
         << cNorm << ".\n";
-    if (isnan(cNorm) || isinf(cNorm))
+    if (std::isnan(cNorm) || std::isinf(cNorm))
       cNorm = 1e-4; // Keep iterating.
 
   } while (cNorm > 1e-5 && iteration != maxIterations);
