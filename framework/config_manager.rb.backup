require "parslet"

module PACKMAN
  class ConfigParser < Parslet::Parser
    rule(:space) { match('\s').repeat(1) }

    rule(:space?) { space.maybe }

    rule(:colon) { str(':') >> space? }

    rule(:comma) { str(',') >> space? }

    rule(:equal_mark) { str('=') >> space? }

    rule(:plus_mark) { str('+') >> space? }

    rule(:minus_mark) { str('-') >> space? }

    rule(:multiply_mark) { str('*') >> space? }

    rule(:divide_mark) { str('/') >> space? }

    rule(:id) { ( match('[A-Za-z_]') >> match('\\w').repeat ).as(:id) >> space? }

    rule(:integer) { match['0-9'].repeat >> space? }

    rule(:float) {
      ( integer >> (
          str('.') >> integer >> (
            match['eE'] >> match['+-'].maybe >>
            integer
          ).maybe
      ).maybe ).as(:float) >> space?
    }

    rule(:string) {
      str('"') >> (
        str('\\') >> any | str('"').absent? >> any
      ).repeat.as(:string) >> str('"') >> space?
    }

    rule(:boolean) {
      ( str('true') | str('false') ).as(:boolean) >> space?
    }

    rule(:operation) {
      ( ( string | id | float ).as(:left) >>
        ( plus_mark | minus_mark | multiply_mark | divide_mark ).as(:op) >>
        expression.as(:right) ).as(:operation)
    }

    rule(:expression) {
      operation | boolean | string | id | float
    }

    rule(:pack_title) {
      id.as(:title) >> colon
    }

    rule(:key_value) {
      id.as(:key) >> equal_mark >> expression.as(:value)
    }

    rule(:config_file) {
      ( pack_title >> ( key_value.repeat ).as(:pairs) ).repeat
    }

    root(:config_file)
  end

  class ConfigPack
    attr_accessor :name, :pairs

    def initialize(name)
      @name = name
      @pairs = {}
    end

    def get_value(key)
      return @pairs[key.to_sym]
    end

    def get_keys
      return @pairs.keys
    end

    def inspect
      @pairs.each_pair do |key, value|
        print "--> #{key}: #{value}\n"
      end
    end
  end

  class ConfigManager
    attr_reader :config_packs

    def initialize
      @config_packs = {}
    end

    def parse(file_path)
      file = File.open(file_path, 'r')
      content = file.read
      begin
        tree = ConfigParser.new.parse(content)
      rescue Parslet::ParseFailed => error
        puts error.cause.ascii_tree
        PACKMAN.report_error "ConfigParser failed to parse!"
      end
      tree.each do |pack|
        name = pack[:title][:id].to_sym
        if @config_packs.has_key? name
          PACKMAN.report_error "Duplicate configuration \"#{name}\"!"
        end
        PACKMAN.report_notice "Add ConfigPack \"#{name}\"."
        @config_packs[name] = ConfigPack.new(name)
        pack[:pairs].each do |pair|
          key = pair[:key][:id].to_sym
          type = pair[:value].keys.first
          value = pair[:value][type]
          @config_packs[name].pairs[key] = evaluate(name, type, value, @config_packs[name].pairs)
        end
      end
    end

    def get_value(pack_name, key, default = nil)
      value = @config_packs[pack_name.to_sym].get_value(key)
      return value if value != nil
      return default if default != nil
      PACKMAN.report_error "Unknown key \"#{key}\" in ConfigPack \"#{pack_name}\"!"
    end

    def get_keys(pack_name)
      return @config_packs[pack_name.to_sym].get_keys
    end

    def inspect
      @config_packs.each_pair do |pack_name, pack|
        print "ConfigPack \"#{pack_name}\":\n"
        pack.inspect
      end
    end

    private

    def evaluate(pack_name, type, value, pairs)
      case type
      when :float
        return value.to_f
      when :string
        return value.to_s
      when :boolean
        if value == 'true'
          return true
        elsif value == 'false'
          return false
        end
      when :operation
        left_type = value[:left].keys.first
        left_value = value[:left][left_type]
        left_final_value = evaluate(pack_name, left_type, left_value, pairs)
        right_type = value[:right].keys.first
        right_value = value[:right][right_type]
        right_final_value = evaluate(pack_name, right_type, right_value, pairs)
        if left_final_value.is_a?(String) || right_final_value.is_a?(String)
          return eval "'#{left_final_value}'#{value[:op]}'#{right_final_value}'"
        else
          return eval "#{left_final_value}#{value[:op]}#{right_final_value}"
        end
      when :id
        return get_value(pack_name, value.to_sym, pairs)
      else
        PACKMAN.report_error "Unknown type \"#{type}\"!"
      end
    end
  end
end
