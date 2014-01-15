require 'grn_mini/util'
require 'groonga'

module GrnMini
  class Array
    attr_accessor :grn
    include Enumerable

    def initialize(name = nil)
      @name  = name || "Array"
      @grn   = Groonga[@name] || Groonga::Array.create(name: @name, persistent: true)
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
      elsif value.is_a?(GrnMini::Array)
        value.grn.name
      elsif value.is_a?(Groonga::Table)
        value.name
      elsif value.is_a?(::Array)
        value_type(value.first)
      else
        raise
      end
    end

    def add(hash)
      setup_columns(hash) unless @setup_columns_once
      @grn.add(hash)
    end

    alias << add

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

    class IdIsGreaterThanZero < RuntimeError; end

    def [](id)
      raise IdIsGreaterThanZero if id == 0
      @grn[id]
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
