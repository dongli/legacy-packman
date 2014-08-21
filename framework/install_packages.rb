module PACKMAN
  def self.install_packages
    reorganize_compiler_sets
    # Install packages.
    ConfigManager.packages.each do |key, value|
      package_name = key.to_s.gsub(/^package_/, '').capitalize
      if not PACKMAN.class_defined?(package_name)
        PACKMAN.report_warning "Unknown package #{Tty.red}#{package_name}#{Tty.reset}!"
        next
      end
      # Parameters need to be set:
      compiler_set_indices = nil
      value.split(/\s*\|\s*/).each do |spec|
        if spec =~ /^compiler_set:/
          tmp = spec.split(/\s*:\s*/)[1]
          begin
            compiler_set_indices = eval "#{tmp}"
          rescue
            PACKMAN.report_error "Bad compiler sets format \"#{spec}\" in package \"#{package_name}\"!"
          end
          if compiler_set_indices.class == Fixnum
            compiler_set_indices = [compiler_set_indices]
          end
          # Validate compiler_set_indices.
          compiler_set_indices.each do |index|
            if index.class != Fixnum
              PACKMAN.report_error "Bad compiler sets format \"#{spec}\" in package \"#{package_name}\"!"
            elsif index >= ConfigManager.compiler_sets.size
              PACKMAN.report_error "Compiler set index is out of range in package \"#{package_name}\"!"
            end
          end
        end
      end
      if not compiler_set_indices
        PACKMAN.report_error "Compiler set indices are not specified for package \"#{package_name}\"!"
      end
      package = eval "#{package_name}.new"
      # Check which compiler sets are to use.
      compiler_sets = []
      for i in 0..ConfigManager.compiler_sets.size-1
        if compiler_set_indices.include?(i)
          compiler_sets.push ConfigManager.compiler_sets[i]
        end
      end
      Package.install(compiler_sets, package)
    end
  end
end
