class Wrf_wps < PACKMAN::Package
  url 'http://www2.mmm.ucar.edu/wrf/src/WPSV3.6.1.TAR.gz'
  sha1 'f6ef8b25593d4d5711e7d6853db4965e60969b88'
  version '3.6.1'

  label 'install_with_source'

  belongs_to 'wrf'

  option 'build_type' => 'serial'
  option 'use_mpi' => :package_name

  depends_on 'netcdf'
  depends_on 'libpng'
  depends_on 'jasper'
  depends_on 'zlib'

  def decompress_to target_dir
    PACKMAN.work_in target_dir do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{filename}"
    end
  end

  def install
    PACKMAN.append_env "NETCDF='#{PACKMAN.prefix Netcdf}'", :ignore
    includes = []
    libs = []
    includes << "#{PACKMAN.prefix Jasper}/include" # NOTE: There is no '-I' ahead!
    libs << "#{PACKMAN.prefix Jasper}/lib" # NOTE: There is no '-L' ahead!
    includes << "-I#{PACKMAN.prefix Zlib}/include"
    libs << "-L#{PACKMAN.prefix Zlib}/lib"
    if not PACKMAN::OS.mac_gang?
      includes << "-I#{PACKMAN.prefix Libpng}"
      libs << "-L#{PACKMAN.prefix Libpng}"
    end
    PACKMAN.append_env "JASPERINC='#{includes.join(' ')}'"
    PACKMAN.append_env "JASPERLIB='#{libs.join(' ')}'"
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
        reader.expect(/./)
      end
      sleep 1
      if not File.exist? './configure.wps'
        PACKMAN.report_error "#{PACKMAN.red 'configure.wps'} is not generated!"
      end
      # Edit WRF_DIR.
      PACKMAN.replace 'configure.wps', {
        /WRF_DIR\s*=.*/ => 'WRF_DIR = ..'
      }
      if PACKMAN::OS.type == :Darwin and ( build_type == 'dmpar' or build_type == 'dm+sm' )
        PACKMAN.replace 'configure.wps', {
          /^(FC\s*=)/ => "DM_FC = mpif90 -fc=$(SFC)\n"+
                         "DM_CC = mpicc -cc=$(SCC)\n\\1"
        }
      end
      # Compile WPS.
      PACKMAN.run './compile'
      # Check if the executables are generated.
      if not File.exist? 'geogrid/src/geogrid.exe' or
         not File.exist? 'metgrid/src/metgrid.exe'
        PACKMAN.report_error 'Failed to build WPS!'
      end
    end
  end

  def choose_platform output
    fortran_compiler_info = PACKMAN.compiler_info 'fortran'
    if build_type == 'serial' or build_type == 'smpar'
      build_type_ = 'serial'
    else
      build_type_ = 'dmpar'
    end
    if fortran_compiler_info[:spec].vendor == 'gnu'
      if fortran_compiler_info[:spec].version <= '4.4.7'
        PACKMAN.report_error "#{PACKMAN.blue 'gfortran'} version "+
          "#{PACKMAN.red fortran_compiler_info[:spec].version} is too low to build WRF!"
      end
      output.each do |line|
        tmp = line.match(/(\d+)\.\s+.*gfortran\s*\(#{build_type_}\)/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not tmp
        return tmp[1]
      end
    elsif fortran_compiler_info[:spec].vendor == 'intel'
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
