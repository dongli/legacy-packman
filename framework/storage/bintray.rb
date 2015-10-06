module PACKMAN
  module Storage
    class Bintray
      def self.init
        @@user = ENV['PACKMAN_BINTRAY_USER']
        @@api_key = ENV['PACKMAN_BINTRAY_API_KEY']
        @@api = 'https://api.bintray.com'
        @@repo = 'binary'
        if is_authenticated?
          require 'rest-client'
          @@client = RestClient::Resource.new(@@api, :user => @@user, :password => @@api_key)
        end
      end

      def self.is_authenticated?
        # TODO: Use Bintray API to authenticate.
        @@user and @@api_key
      end

      def self.upload package, path,  *options
        compiler_set = options.first.class == CompilerSet ? options.first : PACKMAN.active_compiler_set
        create_package(package) if not is_package_exist? package
        name = package.name
        version = Storage.label package, nil, compiler_set
        delete_version(package, compiler_set) if is_version_exist? package, compiler_set
        create_version package, compiler_set
        @@client["/content/packman/#{@@repo}/#{name}/#{version}/#{File.basename(path)};publish=1"].put(
          File.new(path),  :content_type => 'application/octet-stream', :multipart => true) do |resp, req, res, &b|
          if resp.code != 201
            PACKMAN.report_error "Failed to upload package #{PACKMAN.green name} to Bintray!"
          end
        end
      end

      def self.create_package package
        name = package.name
        PACKMAN.report_notice "Create package #{PACKMAN.green name} on Bintray."
        payload = {
          :name => name,
          :desc => "Precompiled package for #{name} created by PACKMAN.",
          :licenses => [ 'Unlicense' ],
          :vcs_url => 'None'
        }.to_json
        @@client["/packages/packman/#{@@repo}"].post(payload, :content_type => :json) do |resp, req, res, &b|
          if resp.code != 201
            p res
            PACKMAN.report_error "Failed to create this package!"
          end
        end
      end

      def self.delete_package package
        name = package.name
        PACKMAN.report_notice "Delete package #{PACKMAN.green name} on Bintray."
        @@client["/packages/packman/#{@@repo}/#{name}"].delete do |resp, req, res, &b|
          if resp.code != 200
            PACKMAN.report_error "Failed to delete this version due to #{PACKMAN.red res.message}!"
          end
        end
      end

      def self.is_package_exist? package
        name = package.name
        @@client["/packages/packman/#{@@repo}/#{name}"].get do |resp, req, res, &b|
          if resp.code != 200
            return false
          else
            return true
          end
        end
      end

      def self.create_version package, compiler_set
        name = package.name
        version = Storage.label package, nil, compiler_set
        PACKMAN.report_notice "Create version #{PACKMAN.blue version} for package #{PACKMAN.green name} on Bintray."
        payload = {
          :name => version,
          :released => Time.now.utc.iso8601
        }.to_json
        @@client["/packages/packman/#{@@repo}/#{name}/versions"].post(payload, :content_type => :json) do |resp, req, res, &b|
          if resp.code != 201
            PACKMAN.report_error "Failed to create this version due to #{PACKMAN.red res.message}!"
          end
        end
      end

      def self.delete_version package, compiler_set
        name = package.name
        version = Storage.label package, nil, compiler_set
        PACKMAN.report_notice "Delete version #{PACKMAN.blue version} for package #{PACKMAN.green name} on Bintray."
        @@client["/packages/packman/#{@@repo}/#{name}/versions/#{version}"].delete do |resp, req, res, &b|
          if resp.code != 200
            PACKMAN.report_error "Failed to delete this version due to #{PACKMAN.red res.message}!"
          end
        end
      end

      def self.is_version_exist? package, compiler_set
        name = package.name
        version = Storage.label package, nil, compiler_set
        @@client["/packages/packman/#{@@repo}/#{name}/versions/#{version}"].get do |resp, req, res, &b|
      	  if resp.code != 200
      	    return false
      	  else
      	    return true
      	  end
      	end
      end
    end
  end
end
