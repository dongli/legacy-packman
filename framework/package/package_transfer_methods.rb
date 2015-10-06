module PACKMAN
  module PackageTransferMethods
    def url; @active_spec.url; end
    def url= val; @active_spec.url val; end
    def sha1; @active_spec.sha1; end
    def version; @active_spec.version; end
    def revision; @active_spec.revision; end
    def filename; @active_spec.filename; end
    def package_path; @active_spec.package_path; end
    def labels; @active_spec.labels; end
    def has_label? val; @active_spec.has_label? val; end
    def conflict_packages; @active_spec.conflict_packages; end
    def conflict_reasons; @active_spec.conflict_reasons; end
    def conflict_with? val; @active_spec.conflict_with? val; end
    def dependencies; @active_spec.dependencies; end
    def master_package; @active_spec.master_package; end
    def patches; @active_spec.patches; end
    def embeded_patches; @active_spec.embeded_patches; end
    def attachments; @active_spec.attachments; end
    def provided_stuffs; @active_spec.provided_stuffs; end
    def binary distro, version; @binary[:"#{distro}:#{version}"]; end
    def option_valid_types; @active_spec.option_valid_types; end
    def options; @active_spec.options; end
    def has_option? key; @active_spec.has_option? key; end
    def update_option key, value, ignore_error = false
      @active_spec.update_option key, value, ignore_error
    end
    def compiler_set; @active_spec.compiler_set; end
  end
end
