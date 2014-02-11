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
      Groonga::Schema.define do |schema|
        schema.change_table(@name) do |table|
          hash.each do |key, value|
            column = key.to_s

            if value.is_a?(::Array)
              table.column(column, value_type(value), type: :vector)
            else
              table.column(column, value_type(value))
            end
          end
        end

        schema.change_table("Terms") do |table|
          hash.each do |key, value|
            column = key.to_s

            if value.is_a?(String)
              table.index("#{@name}.#{column}", with_position: true)
            end
          end
        end

        hash.each do |key, value|
          column = key.to_s
          
          if value.is_a?(::Array)
            elem = value.first
            
            if elem.is_a?(GrnMini::Table)
              schema.change_table(elem.grn.name) do |table|
                table.index("#{@grn.name}.#{column}")
              end
            elsif elem.is_a?(Groonga::Table)
              schema.change_table(elem.name) do |table|
                table.index("#{@grn.name}.#{column}")
              end
            end
          end
        end
      end

      @setup_columns_once = true
    end
    
    def value_type(value)
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        "Bool"
      elsif value.is_a?(Integer)
        "Int32"
      elsif value.is_a?(Float)
        "Float"
      elsif value.is_a?(Time)
        "Time"
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
