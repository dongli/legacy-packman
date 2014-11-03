class Wrf_model < PACKMAN::Package
  url 'http://www2.mmm.ucar.edu/wrf/src/WRFV3.6.1.TAR.gz'
  sha1 '21b398124041b9e459061605317c4870711634a0'
  version '3.6.1'

  label 'install_with_source'

  belongs_to 'wrf'

  option 'build_type' => 'serial'
  option 'use_mpi' => :package_name
  option 'use_nest' => 0
  option 'run_case' => 'em_real'
  option 'with_chem' => false
  if build_type == 'dmpar' or build_type == 'dm+sm'
    if not use_mpi?
      PACKMAN.report_error "MPI library needs to be specified with "+
        "#{PACKMAN.red '-use_mpi=...'} option when building parallel WRF!"
    end
  elsif build_type == 'serial' or build_type == 'smpar'
    if use_mpi?
      PACKMAN.report_error "MPI library should not be specified when building serial WRF!"
    end
  end

  attach do
    url 'http://www2.mmm.ucar.edu/wrf/src/WRFV3-Chem-3.6.1.TAR.gz'
    sha1 '72b56c7e76e8251f9bbbd1d2b95b367ad7d4434b'
    version '3.6.1'
  end

  depends_on 'netcdf'

  def decompress_to target_dir
    PACKMAN.mkdir target_dir
    PACKMAN.work_in target_dir do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{filename}"
      PACKMAN.work_in 'WRFV3' do
        if with_chem?
          chem = attachments.first
          PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{chem.filename}"
        end
      end
    end
  end

  def install
    # Prefix WRF due to some bugs.
    if build_type == 'serial' or build_type == 'smpar'
      PACKMAN.replace 'share/mediation_feedback_domain.F', {
        /(USE module_dm), only: local_communicator/ => '\1'
      }
    end
    # Set compilation environment.
    PACKMAN.append_env "CURL_PATH='#{PACKMAN.prefix Curl}'"
    PACKMAN.append_env "ZLIB_PATH='#{PACKMAN.prefix Zlib}'"
    PACKMAN.append_env "HDF5_PATH='#{PACKMAN.prefix Hdf5}'"
    PACKMAN.append_env "NETCDF='#{PACKMAN.prefix Netcdf}'"
    # Check input parameters.
    if not ['serial', 'smpar', 'dmpar', 'dm+sm'].include? build_type
      PACKMAN.report_error "Invalid build type #{PACKMAN.red build_type}!"
    end
    if not [0, 1, 2, 3].include? use_nest
      PACKMAN.report_error "Invalid nest option #{PACKMAN.red use_nest}!"
    end
    if not ['em_b_wave', 'em_esmf_exp', 'em_fire', 'em_grav2d_x',
            'em_heldsuarez', 'em_hill2d_x', 'em_les', 'em_quarter_ss',
            'em_real', 'em_scm_xy', 'em_seabreeze2d_x', 'em_squall2d_x',
            'em_squall2d_y', 'em_tropical_cyclone', 'exp_real',
            'nmm_real', 'nmm_tropical_cyclone'].include? run_case
      PACKMAN.report_error "Invalid run case #{PACKMAN.red run_case}!"
    end
    PACKMAN.work_in 'WRFV3' do
      # Configure WRF model.
      print "#{PACKMAN.blue '==>'} "
      if PACKMAN::CommandLine.has_option? '-debug'
        print "#{PACKMAN::RunManager.default_command_prefix} ./configure\n"
      else
        print "./configure\n"
      end
      PTY.spawn("#{PACKMAN::RunManager.default_command_prefix} ./configure") do |reader, writer, pid|
        output = reader.expect(/Enter selection.*: /)
        writer.print("#{choose_platform output}\n")
        reader.expect(/Compile for nesting.*: /)
        writer.print("#{use_nest}\n")
        reader.expect(/\*/)
      end
      if not File.exist? 'configure.wrf'
        PACKMAN.report_error "#{PACKMAN.red 'configure.wrf'} is not generated!"
      end
      # Compile WRF model.
      PACKMAN.run './compile', run_case
      # Check if the executables are generated.
      if not File.exist? 'main/wrf.exe'
        PACKMAN.report_error 'Failed to build WRF!'
      end
    end
  end

  def choose_platform output
    c_compiler_info = PACKMAN.compiler_info 'c'
    fortran_compiler_info = PACKMAN.compiler_info 'fortran'
    build_type_ = build_type == 'dm+sm' ? 'dm\+sm' : build_type
    if c_compiler_info[:spec].vendor == 'gnu' and fortran_compiler_info[:spec].vendor == 'gnu'
      if fortran_compiler_info[:spec].version <= '4.4.7'
        PACKMAN.report_error "#{PACKMAN.blue 'gfortran'} version "+
          "#{PACKMAN.red fortran_compiler_info[:spec].version} is too low to build WRF!"
      end
      output.each do |line|
        tmp = line.match(/(\d+)\.\s+.*gfortran\s*\w*\s*with gcc\s+\(#{build_type_}\)/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not tmp
        return tmp[1]
      end
    elsif c_compiler_info[:spec].vendor == 'intel' and fortran_compiler_info[:spec].vendor == 'intel'
      output.each do |line|
        tmp = line.match(/(\d+)\.\s+.*ifort \w* with icc\s+\(#{build_type_}\)/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not tmp
        return tmp[1]
      end
    else
      PACKMAN.report_error 'Unsupported compiler set!'
    end
  end
end
