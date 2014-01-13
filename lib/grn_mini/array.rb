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

        # @todo Need define_index_column ?
        if value.is_a?(Time)
          @grn.define_column(column, "Time")
        elsif value.is_a?(Float)
          @grn.define_column(column, "Float")
        elsif value.is_a?(Numeric)
          @grn.define_column(column, "Int32")
        elsif value.is_a?(String)
          @grn.define_column(column, "ShortText")
          @terms.define_index_column("#{@name}_#{column}", @grn, source: "#{@name}.#{column}", with_position: true)
        else
          raise
        end
      end

      @setup_columns_once = true
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
