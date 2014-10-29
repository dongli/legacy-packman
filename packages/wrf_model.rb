class Wrf_model < PACKMAN::Package
  url 'http://www2.mmm.ucar.edu/wrf/src/WRFV3.6.1.TAR.gz'
  sha1 '21b398124041b9e459061605317c4870711634a0'
  version '3.6.1'

  label 'install_with_source'

  belongs_to 'wrf'

  option 'use_serial' => true
  option 'use_smpar' => false
  option 'use_dmpar' => false
  option 'use_dm_sm' => false
  option 'use_nest' => 0
  option 'run_case' => 'em_real'
  option 'with_chem' => false

  attach do
    url 'http://www2.mmm.ucar.edu/wrf/src/WRFV3-Chem-3.6.1.TAR.gz'
    sha1 '72b56c7e76e8251f9bbbd1d2b95b367ad7d4434b'
    version '3.6.1'
  end

  depends_on 'netcdf'
  depends_on 'libpng'
  depends_on 'jasper'
  depends_on 'zlib'

  def decompress_to target_dir
    PACKMAN.mkdir target_dir
    PACKMAN.work_in target_dir do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{filename}"
      PACKMAN.mv Dir.glob('./WRFV3/*'), '.'
      PACKMAN.rm './WRFV3'
      if with_chem?
        chem = attachments.first
        PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{chem.filename}"
      end
    end
  end

  def install
    PACKMAN.append_env "NETCDF='#{PACKMAN.prefix Netcdf}'"
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
    # Check input parameters.
    if [use_serial?, use_smpar?, use_dmpar?, use_dm_sm?].count(true) != 1
      PACKMAN::CLI.report_error 'Invalid build type!'
    end
    if not [0, 1, 2, 3].include? use_nest
      PACKMAN::CLI.report_error "Invalid nest option #{PACKMAN::CLI.red use_nest}!"
    end
    if not ['em_b_wave', 'em_esmf_exp', 'em_fire', 'em_grav2d_x',
            'em_heldsuarez', 'em_hill2d_x', 'em_les', 'em_quarter_ss',
            'em_real', 'em_scm_xy', 'em_seabreeze2d_x', 'em_squall2d_x',
            'em_squall2d_y', 'em_tropical_cyclone', 'exp_real',
            'nmm_real', 'nmm_tropical_cyclone'].include? run_case
      PACKMAN::CLI.report_error "Invalid run case #{PACKMAN::CLI.red run_case}!"
    end
    # Configure WRF model.
    print "#{PACKMAN::CLI.blue '==>'} "
    if PACKMAN::CommandLine.has_option? '-debug'
      print "#{PACKMAN::RunManager.default_command_prefix} ./configure\n"
    else
      print "./configure\n"
    end
    PTY.spawn("#{PACKMAN::RunManager.default_command_prefix} ./configure") do |reader, writer, pid|
      reader.expect(/Enter selection.*: /)
      writer.print("#{choose_platform}\n")
      reader.expect(/Compile for nesting.*: /)
      writer.print("#{use_nest}\n")
      reader.expect(/\*/)
    end
    if not File.exist? 'configure.wrf'
      PACKMAN::CLI.report_error "#{PACKMAN::CLI.red 'configure.wrf'} is not generated!"
    end
    # Compile WRF model.
    PACKMAN.run './compile', run_case
    PACKMAN.clean_env
  end

  def choose_platform
    c_vendor = PACKMAN.compiler_vendor 'c'
    fortran_vendor = PACKMAN.compiler_vendor 'fortran'
    case PACKMAN::OS.distro
    when :RedHat_Enterprise
      if c_vendor == 'gnu' and fortran_vendor == 'gnu'
        platforms = { :serial => 32, :smpar => 33, :dmpar => 34, :dm_sm => 35 }
      elsif c_vendor == 'intel' and fortran_vendor == 'intel'
        platforms = { :serial => 13, :smpar => 14, :dmpar => 15, :dm_sm => 16 }
      else
        PACKMAN::CLI.report_error 'Unsupported compiler set!'
      end
    when :CentOS
      if c_vendor == 'gnu' and fortran_vendor == 'gnu'
        platforms = { :serial => 5, :smpar => 6, :dmpar => 7, :dm_sm => 8 }
      elsif c_vendor == 'intel' and fortran_vendor == 'intel'
        platforms = { :serial => 15, :smpar => 16, :dmpar => 17, :dm_sm => 18 }
      else
        PACKMAN::CLI.report_error 'Unsupported compiler set!'
      end
    else
      PACKMAN::CLI.report_error "Unsupported OS #{PACKMAN::CLI.red PACKMAN::OS.distro}!"
    end
    if use_serial?
      platforms[:serial]
    elsif use_smpar?
      platforms[:smpar]
    elsif use_dmpar?
      platforms[:dmpar]
    elsif use_dm_sm?
      platforms[:dm_sm]
    end
  end
end
