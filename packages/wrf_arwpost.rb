class Wrf_arwpost < PACKMAN::Package
  url 'http://www2.mmm.ucar.edu/wrf/src/ARWpost_V3.tar.gz'
  sha1 '97a61e0b302fd669c4938e405c7a07cb1c446c9b'
  version '3.1'

  label 'install_with_source'

  belongs_to 'wrf'

  depends_on 'netcdf'

  def decompress_to target_dir
    PACKMAN.mkdir target_dir, :skip_if_exist
    PACKMAN.work_in target_dir do
      PACKMAN.decompress "#{PACKMAN::ConfigManager.package_root}/#{filename}"
    end
  end

  def install
    PACKMAN.append_env 'NETCDF', Netcdf.prefix
    PACKMAN.work_in 'ARWpost' do
      PACKMAN.replace 'arch/configure.defaults', {
        '/lib/cpp' => 'cpp',
        /(#ARCH\s*)(.*)(, gfortran compiler)/ => '\1Darwin \2\3',
        /(#ARCH\s*)(.*)(, Intel compiler)/ => '\1Darwin \2\3'
      }
      PACKMAN.replace 'src/Makefile', '-lnetcdf' => '-lnetcdf -lnetcdff'
      print "#{PACKMAN.blue '==>'} "
      if PACKMAN::CommandLine.has_option? '-debug'
        print "#{PACKMAN::RunManager.default_command_prefix} ./configure with platform "
      else
        print "./configure with platform "
      end
      PTY.spawn("#{PACKMAN::RunManager.default_command_prefix} ./configure") do |reader, writer, pid|
        output = reader.expect(/Enter selection.*: /)
        writer.print("#{choose_platform output}\n")
        PACKMAN.read_eof reader, pid
      end
      if not File.exist? 'configure.arwp'
        PACKMAN.report_error "#{PACKMAN.red 'configure.wrf'} is not generated!"
      end
      PACKMAN.run './compile'
      if not File.exist? 'ARWpost.exe'
        PACKMAN.report_error 'Failed to build ARWpost!'
      end
    end
  end

  def choose_platform output
    fortran_compiler_info = PACKMAN.compiler_info 'fortran'
    matched_platform = nil
    if fortran_compiler_info[:spec].vendor == 'gnu'
      output.each do |line|
        matched_platform = line.match(/(\d+)\.\s+.*gfortran compiler/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not matched_platform
      end
    elsif fortran_compiler_info[:spec].vendor == 'intel'
      output.each do |line|
        matched_platform = line.match(/(\d+)\.\s+.*Intel compiler/)
        PACKMAN.report_error "Mess up with configure output of WRF!" if not matched_platform
      end
    else
      PACKMAN.report_error 'Unsupported compiler set !'
    end
    print "\"#{PACKMAN.green matched_platform}\"\n"
    return matched_platform[1]
  end
end
