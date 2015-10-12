class Wrf_wps < PACKMAN::Package
  url 'http://www2.mmm.ucar.edu/wrf/src/WPSV3.6.1.TAR.gz'
  sha1 'f6ef8b25593d4d5711e7d6853db4965e60969b88'
  version '3.6.1'

  history_version '3.5.1' do
    url 'http://www2.mmm.ucar.edu/wrf/src/WPSV3.5.1.TAR.gz'
    sha1 '5f214825484571c9783b2ee691aa2c9d9cfc6076'
  end

  label :installed_with_source

  belongs_to 'wrf'

  option :build_type => 'serial'
  option :use_mpi => [:package_name, :boolean]

  depends_on :m4
  depends_on :netcdf
  depends_on :libpng
  depends_on :jasper
  depends_on :zlib

  def decompress_to target_dir
    PACKMAN.work_in target_dir do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{filename}"
    end
  end

  def install
    PACKMAN.append_env 'NETCDF', link_root
    PACKMAN.append_env 'JASPERINC', "#{link_root}/include -I#{Libpng.inc}"
    PACKMAN.append_env 'JASPERLIB', "#{link_root}/lib -L#{Libpng.lib}"
    PACKMAN.work_in 'WPS' do
      # Configure WPS.
      print "#{PACKMAN.blue '==>'} "
      if PACKMAN::CommandLine.has_option? '-debug'
        print "#{PACKMAN::RunManager.default_command_prefix} ./configure\n"
      else
        print "./configure\n"
      end
      PTY.spawn("#{PACKMAN::RunManager.default_command_prefix} ./configure") do |reader, writer, pid|
        output = reader.expect(/Enter selection.*: /)
        writer.print("#{choose_platform output}\n")
        PACKMAN.read_eof reader, pid
      end
      sleep 1
      if not File.exist? './configure.wps'
        PACKMAN.report_error "#{PACKMAN.red 'configure.wps'} is not generated!"
      end
      if build_type == 'dmpar' or build_type == 'dm+sm'
        if PACKMAN.mac?
          PACKMAN.replace 'configure.wps', {
            /^(FC\s*=)/ => "DM_FC := mpif90 -fc=$(SFC)\n"+
                           "DM_CC := mpicc -cc=$(SCC)\n\\1"
          }
        else
          PACKMAN.replace 'configure.wps', {
            /mpif90 -f90/ => 'mpif90 -fc'
          }
        end
      end
      PACKMAN.replace 'configure.wps', {
        /SFC\s*=.*/ => "SFC := $(FC)",
        /SCC\s*=.*/ => "SCC := $(CC)"
      }
      if build_type == 'dmpar' or build_type == 'dm+sm'
        PACKMAN.replace 'configure.wps', {
          /DM_FC\s*=.*/ => "DM_FC := $(MPIF90)",
          /DM_CC\s*=.*/ => "DM_CC := $(MPICC)"
        }
      end
      # Compile WPS.
      PACKMAN.run './compile'
      # Check if the executables are generated.
      if not File.exist? 'geogrid/src/geogrid.exe' or
         not File.exist? 'metgrid/src/metgrid.exe' or
         not File.exist? 'ungrib/src/ungrib.exe'
        PACKMAN.report_error 'Failed to build WPS!'
      end
    end
  end

  def choose_platform output
    if build_type == 'serial' or build_type == 'smpar'
      build_type_ = 'serial'
    else
      build_type_ = 'dmpar'
    end
    if PACKMAN.compiler(:fortran).vendor == :gnu
      if PACKMAN.compiler(:fortran).version <= '4.4.7'
        PACKMAN.report_error "#{PACKMAN.blue 'gfortran'} version "+
          "#{PACKMAN.red PACKMAN.compiler(:fortran).version} is too low to build WRF!"
      end
      output.each do |line|
        tmp = line.match(/(\d+)\.\s+.*gfortran\s*\(#{build_type_}\)/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not tmp
        return tmp[1]
      end
    elsif PACKMAN.compiler(:fortran).vendor == :intel
      output.each do |line|
        tmp = line.match(/(\d+)\.\s+.*Intel compiler\s+\(#{build_type_}\)/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not tmp
        return tmp[1]
      end
    else
      PACKMAN.report_error 'Unsupported compiler set!'
    end
  end
end
