module Rael
  class Tuple
    attr_reader :static, :id, :foreign

    @@id = 1
    @@id_hash = {}
    @@tuples = []

    def initialize(
        id: nil,
        static: {},
        translated: {},
        foreign: {}
      )
      @id = id || "_#{@@id}"
      @@id_hash[@id] = self
      @@id += 1

      @static = static
      @translated = translated
      @foreign = foreign

      @@tuples << self
    end

    def translations
      return @translations if @translations

      @translations = []
      translations_hash = { }

      @translated.each do |key, translated_vals|
        translated_vals.each do |lang, val|
          translations_hash[lang] ||= {}
          translations_hash[lang][key] = val
        end
      end

      translations_hash.each do |lang, translation|
        @translations << Rael::Tuple.new(
          static: translation.merge({ :locale => lang })
        )
      end

      @translations
    end

    def attributes
      Struct.new(:keys).new(@static.keys)
    end

    def self.table_name
      "tuples"
    end

    def method_missing(meth, *args, &block)
      if @static.include?(meth)
        return @static[meth]
      elsif @foreign.include?(meth)
        return @foreign[meth]
      elsif @translated.include?(meth)
        return @translated[meth]
      else
        raise("#{meth}: method not found")
      end
    end

    def [](ind)
      if @static.include?(ind)
        return @static[ind]
      elsif @foreign.include?(ind)
        return @foreign[ind]
      elsif @translated.include?(ind)
        return @translated[ind]
      else
        raise("#{ind}: not found")
      end
    end

    def pp
      puts "-"
      puts "id: <#{@id}>"

      if @static.keys.size > 0
        puts "static:\t\t#{@static}"
      end

      if @translated.keys.size > 0
        puts "translated:\t#{@translated}"
      end

      if @foreign.keys.size > 0
        puts "foreign:\t#{@foreign.keys}"
      end
    end

    def self.resolve_foreign_keys
      @@tuples.each do |tuple|
        tuple.foreign.each do |key_name, link|
          if link.is_a?(Array)
            link.each_with_index do |sub_link, sub_link_idx|
              if self.is_link?(sub_link)
                tuple.foreign[key_name][sub_link_idx] = @@id_hash[sub_link]
              end
            end
          else
            if self.is_link?(link)
              tuple.foreign[key_name] = @@id_hash[link]
            end
          end
        end
      end
    end

    def self.is_link?(link)
      if [String, Symbol, Integer].include?(link.class)
        if @@id_hash[link]
          return true
        else
          raise "#{link}: bad link"
        end
      end
    end

    def self.reset
      @@id = 1
      @@id_hash = {}
      @@foreign = {}
    end
  end
end
