module PACKMAN
  module PackageShortcuts
    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def prefix; PACKMAN.prefix self; end
      def bin; prefix+'/bin'; end
      def sbin; prefix+'/sbin'; end
      def etc; prefix+'/etc'; end
      def inc; prefix+'/include'; end
      def lib; prefix+'/lib'; end
      def libexec; prefix+'/libexec'; end
      def share; prefix+'/share'; end
      def doc; share+'/doc/'+self.class.to_s.downcase; end
      def man; share+'/man'; end
      def var; prefix+'/var'; end
      def frameworks; prefix+'/Frameworks'; end
      def info; prefix+'/packman.info'; end
      def link_root; PACKMAN.link_root; end
    end

    module ClassMethods
      def prefix; PACKMAN.prefix self; end
      def bin; prefix+'/bin'; end
      def sbin; prefix+'/sbin'; end
      def etc; prefix+'/etc'; end
      def inc; prefix+'/include'; end
      def lib; prefix+'/lib'; end
      def libexec; prefix+'/libexec'; end
      def share; prefix+'/share'; end
      def doc; share+'/doc/'+self.class.to_s.downcase; end
      def man; share+'/man'; end
      def frameworks; prefix+'/Frameworks'; end
      def info; prefix+'/packman.info'; end
      def var; prefix+'/var'; end
    end
  end
end
