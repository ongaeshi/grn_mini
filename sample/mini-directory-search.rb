require 'grn_mini'
require 'find'
require 'kconv'
require 'sinatra'
require "sinatra/reloader" if ENV['SINATRA_RELOADER']

module Input
  module_function
  
  def from_dir(array, dir = ".")
    puts "Create database .."
    Find.find(File.expand_path(dir)) do |filename|
      Find.prune if ignore_dir?(filename)

      if File.file? filename
        next if ignore_file?(filename)
        array << {filename: filename, text: read_file(filename), timestamp: File.stat(filename).mtime}
      end
    end
    puts "Input complete : #{array.size} files"
  end

  def read_file(filename)
    # p filename
    text = File.read(filename)
    Kconv.kconv(text, Kconv::UTF8).gsub("\r\n", "\n")
  end

  def ignore_dir?(filename)
    basename = File.basename(filename)
    /(\A\.svn\Z)|(\A\.git\Z)|(\ACVS\Z)/.match(basename)
  end

  def ignore_file?(filename)
    s = File.read(filename, 1024) or return false
    return s.index("\x00")
  end
end

if __FILE__ == $PROGRAM_NAME
  array = GrnMini::Array.new("mini-directory-search.db")

  Input.from_dir(array) if array.empty?

  get '/' do
    content = ""

    if params[:query] && !params[:query].empty?
      results = array.select(params[:query])
      snippet = GrnMini::Util::html_snippet_from_selection_results(results)

      elements = []

      results.each do |record|
        element = "<hr>#{record.filename}\n"
        
        snippet.execute(record.text).each do |segment|
          element += "<pre style=\"border:1px solid #bbb;\">#{segment}</pre>\n" # @todo border
        end

        elements << element
      end

      content = elements.join("\n")
    end

<<EOF
<span>#{array.size} files.</span>
<div class="form">
  <form method="post" action="/search">
    <input type="text" style="width: 419px;" name="query" value="#{params[:query]}">
    <input type="submit" value="Search">
  </form>
</div>
<div class="content">
 #{content}
</div>
EOF
  end

  post '/search' do
    redirect "/?query=#{escape(params[:query])}"
  end
end
