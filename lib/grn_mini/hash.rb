require 'grn_mini/util'
require 'groonga'
require 'tmpdir'

module GrnMini
  class Hash
    attr_accessor :grn
    include Enumerable

    def self.tmpdb
      Dir.mktmpdir do |dir|
        # p dir
        yield self.new(File.join(dir, "tmp.db"))
      end
    end

    def initialize(path)
      unless File.exist?(path)
        Groonga::Database.create(path: path)
      else
        Groonga::Database.open(path)
      end

      @grn = Groonga["Hash"] || Groonga::Hash.create(name: "Hash", persistent: true)
      @terms = Groonga["Terms"] || Groonga::PatriciaTrie.create(name: "Terms", key_normalize: true, default_tokenizer: "TokenBigramSplitSymbolAlphaDigit")
    end

    def add(key, values)
      if @grn.empty?
        values.each do |key, value|
          column = key.to_s

          # @todo Need define_index_column ?
          if value.is_a?(Time)
            @grn.define_column(column, "Time")
          elsif value.is_a?(Float)
            @grn.define_column(column, "Float")
          elsif value.is_a?(Numeric)
            @grn.define_column(column, "Int32")
          else
            @grn.define_column(column, "ShortText")
            @terms.define_index_column("array_#{column}", @grn, source: "Hash.#{column}", with_position: true)
          end
        end
      end
      
      @grn.add(key, values)
    end

    def [](key)
      @grn[key]
    end
    
    def []=(key, value)
      add(key, value)
    end

    def select(query, options = {default_column: "text"})
      @grn.select(query, options)
    end

    def size
      @grn.size
    end

    alias length size

    def empty?
      size == 0
    end
    
    def each
      @grn.each do |record|
        yield record
      end
    end

    def delete(id = nil, &block)
      if block_given?
        @grn.delete(&block)
      else
        raise IdIsGreaterThanZero if id == 0
        @grn.delete(id)
      end
    end

    def sort(keys, options = {})
      @grn.sort(keys, options)
    end

    def group(key, options = {})
      @grn.group(key, options)
    end
  end
end