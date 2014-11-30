require "grn_mini/version"
require "grn_mini/array"
require "grn_mini/hash"
require "grn_mini/util"
require 'groonga'
require 'tmpdir'

module GrnMini
  module_function

  def create_or_open(path)
    unless File.exist?(path)
      Groonga::Database.create(path: path)
    else
      Groonga::Database.open(path)
    end
  end

  def tmpdb
    if block_given?
      Dir.mktmpdir do |dir|
        create_or_open(File.join(dir, "tmp.db"))
        yield
      end
    else
      dir = Dir.mktmpdir
      create_or_open(File.join(dir, "tmp.db"))
      dir
    end
  end

  def default_tokenizer
    @default_tokenizer || "TokenBigramSplitSymbolAlphaDigit"
  end

  def default_tokenizer=(tokenizer)
    @default_tokenizer = tokenizer
  end
end
