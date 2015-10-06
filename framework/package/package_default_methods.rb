module PACKMAN
  module PackageDefaultMethods
    def post_install; end
    def check_consistency; true; end
    # def install_method; 'Not available!'; end
  end
end
