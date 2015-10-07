module PACKMAN
  class PackageLabels
    @@ValidLabels = [
      :head,
      :binary,
      :compiler_insensitive,
      :master_package,
      :skipped,
      :try_system_package_first,
      :compiler_set,
      :unlinked
    ]

    def self.check label
      if not @@ValidLabels.include? label
        PACKMAN.report_error "Package label #{PACKMAN.red label} is not valid!"
      end
    end
  end
end
