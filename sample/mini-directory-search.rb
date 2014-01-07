require 'grn_mini'
require 'find'
require 'kconv'
require 'sinatra'
require "sinatra/reloader" if ENV['SINATRA_RELOADER']

module Input
  module_function
  
  def from_dir(array, dir = ".")
    index = 1
    puts "Create database .."
    Find.find(File.expand_path(dir)) do |filename|
      Find.prune if ignore_dir?(filename)

      if File.file? filename
        next if ignore_file?(filename)
        array << {filename: filename, text: read_file(filename), timestamp: File.stat(filename).mtime, suffix: File.extname(filename).sub('.', ""), index: index } # index is dirty
        index += 1
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
        element = "<hr><a href=\"/#{record.index}\">#{record.filename}</a>\n"
        
        snippet.execute(record.text).each do |segment|
          element += "<pre style=\"border:1px solid #bbb;\">#{segment}</pre>\n"
        end

        elements << element
      end

      @header = "<span>#{page_entries.n_records} hit. (#{page_entries.start_offset} - #{page_entries.end_offset})</span>"
      @content = elements.join("\n")

      if page_entries.n_pages > 1
        @pagenation += page_link(@page - 1, "&lt;-") + "&nbsp;" if @page > 1

        @pagenation += page_range(page_entries).map {|v|
          if (v == @page)
            "<strong>#{v.to_s}</strong>"
          else
            page_link(v, v.to_s)
          end
        }.join("&nbsp;")

        @pagenation += "&nbsp;" + page_link(@page + 1, "-&gt;") if @page < page_entries.n_pages
      end
      
    else
      @header = "<span>#{@array.size} files.</span>"
    end
  end

  def page_range(page_entries)
    first_diff = [5 - (@page - 1), 0].max
    last_diff  = [5 - (page_entries.n_pages - @page), 0].max
    [@page - 5 - last_diff, 1].max .. [@page + 5 + first_diff, page_entries.n_pages].min
  end

  def page_link(page, msg)
    "<a href=\"/?query=#{@params[:query]}&page=#{page}\">#{msg}</a>"
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
configure do
  $array = GrnMini::Array.new("mini-directory-search.db")
  Input.from_dir($array) if $array.empty?
end

get '/' do
  search = Search.new($array, params)
  search.parse
  search.html
end

get '/:id' do
  record = $array[params[:id].to_i]
  
  <<EOF
<span>#{record.filename}</span>
<div class="form">
  <form method="post" action="/search">
    <input type="text" style="width: 419px;" name="query" value="#{@params[:query]}">
    <input type="submit" value="Search">
  </form>
</div>
<div class="content">
<hr>
<pre>#{CGI.escapeHTML(record.text)}</pre>
</div>
EOF
end

post '/search' do
  redirect "/?query=#{escape(params[:query])}"
end
