require 'grn_mini'
require 'find'
require 'kconv'

def read_file(filename)
  # p filename
  text = File.read(filename)
  Kconv.kconv(text, Kconv::UTF8).gsub("\r\n", "\n")
end

def ignore_dir?(filename)
  basename = File.basename(filename)
  /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/.match(basename)
end

def binary?(fpath)
  s = File.read(fpath, 1024) or return false
  return s.index("\x00")
end

def ignore_file?(filename)
  binary?(filename)
end

def input_data(array, dir = ".")
  Find.find(File.expand_path(dir)) do |filename|
    Find.prune if ignore_dir?(filename)

    if File.file? filename
      next if ignore_file?(filename)
      array << {filename: filename, text: read_file(filename), timestamp: File.stat(filename).mtime}
    end
    puts "Input : #{array.size}" if array.size > 0 && array.size % 100 == 0
  end
  puts "Input complete : #{array.size} files"
end

if __FILE__ == $PROGRAM_NAME
  array = GrnMini::Array.new("mini-directory-search.db")

  input_data(array) if array.empty?
end
