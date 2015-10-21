module PACKMAN
  module PackageDefaultMethods
    def post_install; end
    def check_consistency; true; end
    # def install_method; 'Not available!'; end
    def before_link; end
  end
end
