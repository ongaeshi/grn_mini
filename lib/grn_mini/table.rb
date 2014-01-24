require 'grn_mini/util'
require 'groonga'

module GrnMini
  class NotSupportColumnType < RuntimeError; end

  class Table
    attr_accessor :grn
    include Enumerable

    def initialize(name, grn)
      @name = name
      @grn  = grn
      @terms = Groonga["Terms"] || Groonga::PatriciaTrie.create(name: "Terms", key_normalize: true, default_tokenizer: "TokenBigramSplitSymbolAlphaDigit")
      @setup_columns_once = false
    end

    def setup_columns(hash)
      hash.each do |key, value|
        column = key.to_s

        if value.is_a?(String)
          @grn.define_column(column, value_type(value))
          @terms.define_index_column("#{@name}_#{column}", @grn, source: "#{@name}.#{column}", with_position: true)
        elsif value.is_a?(::Array)
          @grn.define_column(column, value_type(value), type: :vector)

          elem = value.first
          
          if elem.is_a?(GrnMini::Table)
            elem.grn.define_index_column("index_#{column}", @grn, source: "#{@grn.name}.#{column}")
          elsif elem.is_a?(Groonga::Table)
            elem.define_index_column("index_#{column}", @grn, source: "#{@grn.name}.#{column}")
          end
        else
          @grn.define_column(column, value_type(value))
        end
      end

      @setup_columns_once = true
    end
    
    def value_type(value)
      if value.is_a?(Time)
        "Time"
      elsif value.is_a?(Float)
        "Float"
      elsif value.is_a?(Numeric)
        "Int32"
      elsif value.is_a?(String)
        "ShortText"
      elsif value.is_a?(GrnMini::Table)
        value.grn.name
      elsif value.is_a?(Groonga::Table)
        value.name
      elsif value.is_a?(::Array)
        value_type(value.first)
      else
        raise NotSupportColumnType, value
      end
    end

    def select(*args, &block)
      @grn.select(*args, &block)
    end
    
    def size
      @grn.size
    end

    def empty?
      size == 0
    end

    def each
      @grn.each do |record|
        yield record
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
