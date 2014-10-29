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
    includes << "-I#{PACKMAN.prefix Jasper}/include"
    libs << "-L#{PACKMAN.prefix Jasper}/lib"
    includes << "-I#{PACKMAN.prefix Zlib}/include"
    libs << "-L#{PACKMAN.prefix Zlib}/lib"
    if not PACKMAN::OS.mac_gang?
      includes << "-I#{PACKMAN.prefix Libpng}"
      libs << "-L#{PACKMAN.prefix Libpng}"
    end
    PACKMAN.append_env "JASPERINC='#{includes.join(' ')}'"
    PACKMAN.append_env "JASPERLIB='#{libs.join(' ')}'"
    # Check input parameters.
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
      reader.expect(/Enter selection \[1-63\] : /)
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
    os_type = PACKMAN::OS.type
    c_vendor = PACKMAN.compiler_vendor 'c'
    fortran_vendor = PACKMAN.compiler_vendor 'fortran'
    if os_type == :Linux or os_type == :Darwin
      if c_vendor == 'gnu' and fortran_vendor == 'gnu'
        if use_serial?
          platform = 32
        elsif use_smpar?
          platform = 33
        elsif use_dmpar?
          platform = 34
        elsif use_dm_sm?
          platform = 35
        end
      elsif c_vendor == 'intel' and fortran_vendor == 'intel'
        if use_serial?
          platform = 13
        elsif use_smpar?
          platform = 14
        elsif use_dmpar?
          platform = 15
        elsif use_dm_sm?
          platform = 16
        end
      else
        PACKMAN::CLI.under_construction!
      end
    else
      PACKMAN::CLI.under_construction!
    end
    return platform
  end
end
