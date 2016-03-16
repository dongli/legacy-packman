class Hpx < PACKMAN::Package
  url 'https://github.com/STEllAR-GROUP/hpx/archive/0.9.11.tar.gz'
  sha1 'ecd186ca05b9f14dbbb4cff69739e28d5dd3d66f'
  version '0.9.11'
  filename 'hpx-0.9.11.tar.gz'

  head do
    git 'https://github.com/STEllAR-GROUP/hpx.git'
  end

  depends_on :boost
  depends_on :hwloc

  def install
    args = %W[
      -DCMAKE_BUILD_TYPE=Relase
      -DCMAKE_CXX_COMPILER=#{PACKMAN.compiler(:cxx).command}
      -DBOOST_ROOT=#{PACKMAN.link_root}
      -DHWLOC_ROOT=#{PACKMAN.link_root}
      -DCMAKE_INSTALL_PREFIX=#{prefix}
    ]
    PACKMAN.mkdir 'build'
    PACKMAN.work_in 'build' do
      PACKMAN.run 'cmake ..', *args
      PACKMAN.run 'make -j2'
      PACKMAN.run 'make -j2 install'
    end
  end
end
