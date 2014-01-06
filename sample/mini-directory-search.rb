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

class Search
  def initialize(array, params)
    @array   = array
    @params  = params
    @page    = @params[:page] ? @params[:page].to_i : 1
    @header  = ""
    @content = ""
    @pagenation = ""
  end

  def parse
    if @params[:query] && !@params[:query].empty?
      results = @array.select(@params[:query])
      snippet = GrnMini::Util::html_snippet_from_selection_results(results, "<strong style=\"background-color: #FFEE55\">", "</strong>")

      page_entries = results.paginate([["_score", :desc]], :page => @page, :size => 20)
      elements = []

      page_entries.each do |record|
        element = "<hr>#{record.filename}\n"
        
        snippet.execute(record.text).each do |segment|
          element += "<pre style=\"border:1px solid #bbb;\">#{segment}</pre>\n"
        end

        elements << element
      end

      @header = "<span>#{page_entries.n_records} hit. (#{page_entries.start_offset} - #{page_entries.end_offset})</span>"
      @content = elements.join("\n")

      if page_entries.n_pages > 1
        @pagenation += "<a href=\"/?query=#{@params[:query]}&page=#{@page - 1}\">&lt;-</a>&nbsp;" if @page > 1
        
        @pagenation += page_entries.pages.map {|v|
          if (v == @page)
            "<strong>#{v.to_s}</strong>"
          else
            "<a href=\"/?query=#{@params[:query]}&page=#{v}\">#{v}</a>"
          end
        }.join("&nbsp;")

        @pagenation += "&nbsp;<a href=\"/?query=#{@params[:query]}&page=#{@page + 1}\">-&gt;</a>&nbsp;" if @page < page_entries.n_pages
      end
      
    else
      @header = "<span>#{@array.size} files.</span>"
    end
  end

  def html
    <<EOF
#{@header}
<div class="form">
  <form method="post" action="/search">
    <input type="text" style="width: 419px;" name="query" value="#{@params[:query]}">
    <input type="submit" value="Search">
  </form>
</div>
<div class="content">
 #{@content}
</div>
<div class="pagenation">
 #{@pagenation}
</div>
EOF
  end
end

# main
array = GrnMini::Array.new("mini-directory-search.db")
Input.from_dir(array) if array.empty?

get '/' do
  search = Search.new(array, params)
  search.parse
  search.html
end

post '/search' do
  redirect "/?query=#{escape(params[:query])}"
end
