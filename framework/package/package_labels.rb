module PACKMAN
  class PackageLabels
    @@ValidLabels = [
      :binary,
      :compiler_insensitive,
      :installed_with_source,
      :master_package,
      :not_set_bashrc,
      :not_set_ld_library_path,
      :skipped,
      :try_system_package_first,
      :under_construction
    ]

    def self.check label
      if not @@ValidLabels.include? label
        PACKMAN.report_error "Package label #{PACKMAN.red label} is not valid!"
      end
    end
  end
end