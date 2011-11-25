##   RSence
 #   Copyright 2009 Riassence Inc.
 #   http://riassence.com/
 #
 #   You should have received a copy of the GNU General Public License along
 #   with this software package. If not, contact licensing@riassence.com
 ##


require 'jsmin_c'
require 'jscompress'
require 'html_min'
begin
  require 'coffee-script'
  RSence.config[:client_pkg][:coffee_supported] = true
rescue LoadError
  warn "CoffeeScript not installed. Install the 'coffee-script' gem to enable."
  RSence.config[:client_pkg][:coffee_supported] = false
end


class ClientPkgBuild
  
  def read_file( path )
    filehandle = open( path, 'rb' )
    filedata   = filehandle.read
    filehandle.close
    return filedata
  end
  
  def gzip_string( string )
    gz_string = GZString.new('')
    gz_writer = Zlib::GzipWriter.new( gz_string, @gz_strategy )
    gz_writer.write( string )
    gz_writer.close
    return gz_string
  end
  
  def read_css( src_path )
    css_data = read_file( src_path )
    unless @debug
      unless @no_whitespace_removal
        css_data = @html_min.minimize( css_data )
        if @css_min
          css_data = CSSMin.minify( css_data )
        end
      end
    end
    if @no_gzip
      gz_css = false
    else
      gz_css = gzip_string( css_data )
    end
    return [css_data, gz_css]
  end
  
  def read_html( src_path )
    html_data = read_file( src_path )
    unless @debug
      unless @no_whitespace_removal
        html_data = @html_min.minimize( html_data )
      end
    end
    if @no_gzip
      gz_html = false
    else
      gz_html = gzip_string( html_data )
    end
    return [html_data, gz_html]
  end
  
  def read_gfx( src_path_theme, tgt_hash_gfx )
    gfx_size = 0
    src_files_gfx_path = File.join( src_path_theme, 'gfx' )
    [ src_path_theme, src_files_gfx_path ].each do |src_files_gfx|
      if File.exist?( src_files_gfx )
        Dir.entries( src_files_gfx ).each do |src_gfx_filename|
          src_file_gfx = File.join( src_files_gfx, src_gfx_filename )
          if @gfx_formats.include?( src_file_gfx[-4..-1] )
            tgt_hash_gfx[src_gfx_filename] = read_file( src_file_gfx )
            gfx_size += File.stat( src_file_gfx ).size
          end
        end
      end
    end
    return gfx_size
  end
  
  # processes theme-related files
  def read_theme( bundle_dir, bundle_name )
    @theme_names.each do |theme_name|
      @theme_sizes[ theme_name ] = {
        :css  => [0,0],
        :html => [0,0],
        :gfx  => 0
      } unless @theme_sizes.has_key?( theme_name )
      tgt_hash_theme = @themes[theme_name]
      src_path_theme = File.join( bundle_dir, 'themes', theme_name )
      [ File.join( src_path_theme, bundle_name+'.css' ),
        File.join( src_path_theme, 'css', bundle_name+'.css' )
      ].each do |src_file_css|
        if File.exist?( src_file_css )
          ( css_data, gz_css ) = read_css( src_file_css )
          tgt_hash_css = tgt_hash_theme[:css][bundle_name] = {
            :data => css_data,
            :gzip => gz_css
          }
          @theme_sizes[   theme_name ][:css][0] += File.stat( src_file_css ).size
          @theme_sizes[   theme_name ][:css][1] += css_data.bytesize
          @css_by_theme[  theme_name ][ bundle_name ] = css_data
        end
      end
      [ File.join( src_path_theme, bundle_name+'.html' ),
        File.join( src_path_theme, 'html', bundle_name+'.html' )
      ].each do |src_file_html|
        if File.exist?( src_file_html )
          ( html_data, gz_html ) = read_html( src_file_html )
          tgt_hash_html = tgt_hash_theme[:html][bundle_name] = {
            :data => html_data,
            :gzip => gz_html
          }
          @theme_sizes[   theme_name ][:html][0] += File.stat( src_file_html ).size
          @theme_sizes[   theme_name ][:html][1] += html_data.bytesize
          @html_by_theme[ theme_name ][ bundle_name ] = html_data
        end
      end
      tgt_hash_gfx = tgt_hash_theme[:gfx]
      gfx_size = read_gfx( src_path_theme, tgt_hash_gfx )
      @theme_sizes[   theme_name ][:gfx] += gfx_size
    end
  end
  
  def add_bundle( bundle_name, bundle_path, entries, has_js=false, has_coffee=false )
    has_themes = entries.include?( 'themes' ) and File.directory?( File.join( bundle_path, 'themes' ) )
    if @bundles_found.has_key?( bundle_name )
      @logger.log( "JSBuilder ERROR: duplicate bundles with the name #{bundle_name.inspect} found." )
      @logger.log( "    The first encountered is #{@bundles_found[ bundle_name ].inspect}" )
      @logger.log( "    The second encountered is #{bundle_path.inspect}" )
      @logger.log( "abort." )
      return false
    end
    unless @destinations.include?( bundle_name )
      warn "JSBuilder WARNING: bundle name #{bundle_name.inspect} does not belong to any package, skipping.." if ARGV.include?('-d')
      return true
    end
    if has_coffee and @coffee_supported
      begin
        coffee_start = Time.new.to_f
        coffee_path = File.join( bundle_path, bundle_name+'.coffee' )
        coffee_timestamp = File.stat( coffee_path ).mtime.to_i
        has_cache_compiled = @coffee_cache[:path_compiled].has_key?( coffee_path )
        has_cache_timestamp = @coffee_cache[:path_timestamp].has_key?( coffee_path )
        has_cache_entry = has_cache_compiled and has_cache_timestamp
        has_cached = ( has_cache_entry and ( @coffee_cache[:path_timestamp][coffee_path] == coffee_timestamp ) )
        if has_cached
          js_data = @coffee_cache[:path_compiled][coffee_path]
        else
          coffee_src = read_file( coffee_path )
          js_data = CoffeeScript.compile( coffee_src, :bare => true )
          @coffee_cache[:path_timestamp][coffee_path] = coffee_timestamp
          @coffee_cache[:path_compiled][coffee_path] = js_data
        end
        @coffee_time += ( Time.new.to_f - coffee_start )
      rescue CoffeeScript::CompilationError
        if has_js
          js_data = %{console.log( "WARNING: CoffeeScript complilation failed for source file #{coffee_path}, using the js variant instead." );}
          js_data += read_file( File.join( bundle_path, bundle_name+'.js' ) )
        else
          js_data = %{console.log( "WARNING: CoffeeScript complilation failed for source file #{coffee_path}" );}
        end
      end
    elsif not has_js
      js_data = %{console.log( "ERROR: CoffeeScript not suuported and no JS source available for #{bundle_path}" );}
    else
      js_data = read_file( File.join( bundle_path, bundle_name+'.js' ) )
    end
    @bundles_found[ bundle_name ] = {
      :path => bundle_path,
      :js_data => js_data,
      :js_size => js_data.bytesize,
      :has_themes => has_themes
    }
    if has_themes
      read_theme( bundle_path, bundle_name )
    end
    return true
  end
  
  def find_bundles( src_dir )
    # makes sure the src_dir exists and is a directory
    if File.exist?( src_dir ) and File.directory?( src_dir )
      # array of item names in dir
      dir_entries = Dir.entries( src_dir )
      # the name of src_dir (src_dir itself is a full path)
      dir_name    = File.split( src_dir )[1]
      # bundles are defined as directories with a js file of the same name plus the 'js.inc' tagfile
      not_disabled = ( not dir_entries.include?( 'disabled' ) )
      has_js = dir_entries.include?( dir_name+'.js' )
      has_coffee = dir_entries.include?( dir_name+'.coffee' )
      is_bundle   = not_disabled and ( has_js or has_coffee )
      # if src_dir is detected as a bundle, handle it in add_bundle
      if is_bundle
        add_bundle( dir_name, src_dir, dir_entries, has_js, has_coffee )
      end
      # descend into the sub-directory:
      dir_entries.each do | dir_entry |
        # don't descend into themes or hidden dirs:
        next if dir_entry[0].chr == '.' or dir_entry == 'themes'
        sub_dir = File.join( src_dir, dir_entry )
        find_bundles( sub_dir ) if File.directory?( sub_dir )
      end
    end
  end
  
  def build_indexes
    indexes = []
    @destination_files.each_key do | package_name |
      indexes.push( @destination_files[ package_name ] )
    end
    @jscompress.build_indexes( indexes.join("\n") ) unless @no_obfuscation
  end
  
  def pre_convert(jsc_data)
    return @jscompress.compress( jsc_data )
  end
  
  def minimize_data
    unless @quiet
      @logger.log(  '' )
      @logger.log(  "Client package build report.......................#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}" )
      @logger.log(  '' )
      @logger.log(  "JS Package....................:  Original |   Minimized |  Compressed" )
      @logger.log(  "                              :           |             |" )
    end
    @destination_files.each_key do | package_name |
      jsc_data = process_js( @destination_files[package_name] )
      @js[package_name] = jsc_data
      unless @no_gzip
        gz_data = gzip_string( jsc_data )
        @gz[package_name] = gz_data
      end
      unless @quiet
        js_size  = @destination_files[ package_name ].bytesize
        jsc_size = jsc_data.bytesize
        if @no_gzip
          gz_size  = -1
        else
          gz_size  = gz_data.bytesize
        end
        print_stat( package_name, js_size, jsc_size, gz_size )
      end
    end
  end
  
  def squeeze( js, is_coffee=false )
    unless @no_whitespace_removal
      begin
        js = @jsmin.minimize( js )#.strip
      rescue IndexError => e
        warn "js can't get smaller using js; just ignoring jsmin"
      end
    end
    unless @no_obfuscation
      @jscompress.build_indexes( js )
      js = @jscompress.compress( js )
    end
    return js.strip
  end

  def coffee( src )
    begin
      js = CoffeeScript.compile( src, :bare => true )
    rescue ExecJS::RuntimeError => e
      warn "ExecJS RuntimeError, invalid CoffeScript supplied:\n----\n#{src}----\n"
      js = "function(){console.log('ERROR; invalid CoffeeScript supplied: #{src.to_json}');}"
    rescue CoffeeScript::CompilationError
      warn "Invalid CoffeeScript supplied:\n----\n#{src}----\n"
      js = "function(){console.log('ERROR; invalid CoffeeScript supplied: #{src.to_json}');}"
    end
    js = squeeze( js )
    return js[1..-3] if js.start_with?('(') and js.end_with?(');')
    return js
  end

  def process_js( src_in )
    if @debug
      return src_in
    else
      src_out = src_in
      src_out = @jsmin.minimize( src_out ) unless @no_whitespace_removal
      src_out = pre_convert( src_out ) unless @no_obfuscation
      return src_out.strip
    end
  end
  
  def build_themes
    unless @quiet
      @logger.log(  '' )
      @logger.log(  "Theme name and part...........:  Original |   Minimized |  Compressed" )
      @logger.log(  "                              :           |             |" )
    end
    # compile "all-in-one" css and html resources
    @theme_names.each do |theme_name|
      html_templates = @html_by_theme[ theme_name ]
      css_templates  = @css_by_theme[  theme_name ]
      theme_css_template_data = css_templates.values.join("\n")
      theme_html_js_arr = []
      theme_html_js_arr.push "HThemeManager._tmplCache[#{theme_name.to_json}]=#{html_templates.to_json}; "
      theme_html_js_arr.push "HNoComponentCSS.push(#{theme_name.to_json});"
      theme_html_js_arr.push "HNoCommonCSS.push(#{theme_name.to_json});"
      theme_html_js_arr.push %{
        HThemeManager._pushStart( function(){
          var _this = HThemeManager;
          _this._cssUrl( #{theme_name.to_json}, #{(theme_name+'_theme').to_json}, _this.themePath, null );
          _this.useCSS(#{theme_css_template_data.to_json});
        } );
      }
      theme_html_js = process_js( theme_html_js_arr.join('') )
      @js[theme_name+'_theme'] = theme_html_js
      unless @no_gzip
        theme_html_gz = gzip_string( @js[theme_name+'_theme'] )
        @gz[theme_name+'_theme'] = theme_html_gz
      end
      unless @quiet
        print_stat( "#{theme_name}/html", @theme_sizes[theme_name][:html][0], @theme_sizes[theme_name][:html][1], theme_html_gz.bytesize )
      end
      @themes[theme_name][:css][theme_name+'_theme'] = {
        :data => theme_css_template_data,
        :gzip => false
      }
      unless @no_gzip
        theme_css_template_data_gz = gzip_string( theme_css_template_data )
        @themes[theme_name][:css][theme_name+'_theme'][:gzip] = theme_css_template_data_gz
      end
      unless @quiet
        print_stat( "#{theme_name}/css", @theme_sizes[theme_name][:css][0], @theme_sizes[theme_name][:css][1], theme_css_template_data_gz.bytesize )
        print_stat( "#{theme_name}/gfx", @theme_sizes[theme_name][:gfx], -1, -1 )
        @logger.log( '' )
      end
    end
  end
  
  def build_compound_packages
    unless @quiet
      @logger.log(  '' )
      @logger.log(  "Compound package..............:  Original |   Minimized |  Compressed" )
      @logger.log(  "                              :           |             |" )
    end
    @compound_config.each do |pkg_name, js_order|
      pkg_parts = []
      js_order.each do |js_pkg|
        pkg_part = @js[ js_pkg ]
        pkg_parts.push( pkg_part )
      end
      js_src = pkg_parts.join('')
      @js[ pkg_name ] = js_src
      unless @no_gzip
        gz_data = gzip_string( js_src )
        @gz[ pkg_name ] = gz_data
      end
      unless @quiet
        js_size  = js_src.bytesize
        if @no_gzip
          gz_size  = -1
        else
          gz_size  = gz_data.bytesize
        end
        print_stat( pkg_name, js_size, -1, gz_size )
      end
    end
  end

  def run
    
    time_start = Time.now.to_f*10000
    @coffee_time = 0
    
    # hash of bundles per bundle name per theme; @html_by_theme[theme_name][bundle_name] = bundle_data
    @html_by_theme = {}
    @css_by_theme  = {}
    @theme_names.each do | theme_name |
      @html_by_theme[ theme_name ] = {}
      @css_by_theme[  theme_name ] = {}
    end
    @theme_sizes = {}
    # hash of bundle -> package mappings (reverse @packages)
    @destinations = {}
    @package_names.each do | package_name |
      @packages[ package_name ].each do |bundle_name|
        @destinations[ bundle_name ] = [] unless @destinations.include?( bundle_name )
        @destinations[ bundle_name ].push( package_name )
      end
    end
    @bundles_found = {} # populated by add_bundle
    @conversion_stats = {} # populated by add_hints
    src_dirs = @src_dirs.clone
    src_dirs.each do | src_dir |
      find_bundles( src_dir )
    end
    @destination_files = {} # rename to package_products
    @package_names.each do |package_name|
      @packages[package_name].each do |bundle_name|
        if @bundles_found.has_key?( bundle_name )
          @destination_files[ package_name ] = [] unless @destination_files.has_key?( package_name )
          @destination_files[ package_name ].push( @bundles_found[bundle_name][:js_data] )
        end
      end
    end
    @destination_files.each do | package_name, package_array |
      package_data = package_array.join('')
      @destination_files[ package_name ] = package_data
    end
    
    build_indexes
    build_themes
    minimize_data
    build_compound_packages
    
    ms_taken = ((Time.now.to_f*10000)-time_start).round/10.0
    coffee_taken = (@coffee_time*10000).round/10.0
    without_coffee = ((ms_taken - coffee_taken)*10).round/10.0
    @logger.log( "Time taken:\n .coffee: #{coffee_taken}ms\n  other:  #{without_coffee}ms\n  total:  #{ms_taken}ms\n\n" )
    
  end
  
  def setup_dirs
    # make sure the src_dirs contain only absolute paths.
    # if not, use current working dir as a logical prefix
    @src_dirs.map! do |src_dir|
      File.expand_path( src_dir )
    end
    
    @src_dirs.each do |src_dir|
      # exit with error if the src dir does not exist
      unless File.exist?( src_dir )
        @logger.log( "JSBuilder ERROR: the source directory #{src_dir.inspect} does not exist." )
        @logger.log( "abort." )
        return false
      end
      
    end
    
    @package_names.each do |package_name|
      @js[package_name] = ''
      @gz[package_name] = ''
    end
    
    # ensures the destination directories of various theme parts exist
    @theme_names.each do |theme_name|
      @themes[theme_name] = {
        :css  => {},
        :html => {},
        :gfx  => {}
      }
    end
    
    return true
    
  end
  
  def add_src_dir( src_dir )
    @src_dirs.push( src_dir ) unless @src_dirs.include? src_dir
  end
  def add_src_dirs( src_dirs )
    src_dirs.each { |src_dir| add_src_dir( src_dir ) }
  end
  def del_src_dir( src_dir )
    @src_dirs.delete( src_dir ) if @src_dirs.include? src_dir
  end
  def del_src_dirs( src_dirs )
    src_dirs.each { |src_dir| del_src_dir( src_dir ) }
  end
  
  def add_theme( theme_name )
    @theme_names.push( theme_name ) unless @theme_names.include? theme_name
  end
  def add_themes( theme_names )
    theme_names.each { |theme_name| add_theme( theme_name ) }
  end
  def del_theme( theme_name )
    @theme_names.delete( theme_name ) if @theme_names.include? theme_name
  end
  def del_themes( theme_names )
    theme_names.each { |theme_name| del_theme( theme_name ) }
  end
  
  def add_package( pkg_name, pkg_items )
    if @packages.has_key?( pkg_name )
      warn "Package #{pkg_name} already exists, ignoring."
    else
      @packages[ pkg_name ] = pkg_items
      @package_names = @packages.keys
    end
  end
  def add_packages( packages )
    packages.each do | pkg_name, pkg_items |
      add_package( pkg_name, pkg_items )
    end
  end
  def del_package( pkg_name )
    if @packages.has_key?( pkg_name )
      @packages.delete( pkg_name )
      @package_names = @packages.keys
    end
  end
  def del_packages( packages )
    packages.each { |pkg_name| del_package( pkg_name ) }
  end
  
  def add_reserved_name( reserved_name )
    @reserved_names.push( reserved_name ) unless @reserved_names.include? reserved_name
  end
  def add_reserved_names( reserved_names )
    reserved_names.each { |n| add_reserved_name( n ) }
  end
  def del_reserved_name( reserved_name )
    @reserved_names.delete( reserved_name ) if @resered_names.include? reserved_name
  end
  def del_reserved_names( reserved_names )
    reserved_names.each { |n| del_reserved_name( n ) }
  end
  
  def add_gfx_format( gfx_format )
    @gfx_formats.push( gfx_format ) unless @gfx_formats.include? gfx_format
  end
  def add_gfx_formats( gfx_formats )
    gfx_formats.each { |gfx_format| add_gfx_format( gfx_format ) }
  end
  def del_gfx_format( gfx_format )
    @gfx_formats.delete( gfx_format ) if @gfx_formats.include? gfx_format
  end
  def del_gfx_formats( gfx_formats )
    gfx_formats.each { |gfx_format| del_gfx_format( gfx_format ) }
  end
  
  #delete: @js_dst_dir, @themes_dst_dir, 
  
  attr_reader :js, :gz, :themes, :jsmin, :jscompress
  
  def initialize( config, logger )
    
    @coffee_supported = config[:coffee_supported]
    @coffee_cache = {
      :path_timestamp => {},
      :path_compiled => {}
    }

    @logger = logger
    
    # src_dirs is supposed to be an array of js source directories
    @src_dirs = config[:src_dirs]
    
    @js = {}
    @gz = {}
    @themes = {}
    
    # theme_names is supposed to be an array of theme names to include in the build
    @theme_names = config[:theme_names]
    
    # pkg_info is supposed to be a hash of js package name definitions by pkg_name
    @packages = config[:packages]
    
    # packages is supposed to be a list of js package name definitions to include
    @package_names = @packages.keys
    
    # reserved_names is supposed to be a list of reserved words (words that shouldn't be compressed)
    @reserved_names = config[:reserved_names]
    
    # JSCompress compresses js by "obfuscating" 
    # all variables beginning with an underscore "_",
    # eg. "_this" -> "_0", except
    # those specified in the @reserved_names array
    @jscompress = JSCompress.new( config[:reserved_names] )
    
    # HTMLMin compresses css and html by removing whitespace
    @html_min = HTMLMin.new
    
    # JSMin removes js white-space (makes the source shorter)
    @jsmin = JSMin.new
    
    # makes sure the specified dirs are ok
    return if not setup_dirs
    
    begin
      require 'rubygems'
      require 'cssmin'
      @css_min = true
    rescue LoadError => e
      warn "cssmin not installed. install cssmin (gem install cssmin) to improve the css minifiying."
      @css_min = false
    end
    
    # contains a list of theme gfx extensions allowed
    @gfx_formats = config[:gfx_formats]
    
    # compression strategy ( fastest vs smallest )
    @gz_strategy = config[:gz_strategy]
    @no_gzip = config[:no_gzip]
    @no_obfuscation = config[:no_obfuscation]
    @no_whitespace_removal = config[:no_whitespace_removal]
    @debug = RSence.args[:debug]
    @quiet = (not RSence.args[:verbose])
    @compound_config = config[:compound_packages]
  end
  
  def find_newer( src_dir, newer_than )
   if File.exist?( src_dir ) and File.directory?( src_dir )
     Dir.entries( src_dir ).each do | dir_entry |
       next if dir_entry[0].chr == '.'
       sub_dir = File.join( src_dir, dir_entry )
       if File.directory?( sub_dir )
         return true if find_newer( sub_dir, newer_than )
       else
         if newer_than < File.stat( sub_dir ).mtime.to_i
           @logger.log( "File changed: #{sub_dir}" )
           return true
         end
       end
     end
   end
   return false
  end
  
  def bundle_changes( newer_than )
   @bundles_found.each do | bundle_name, bundle_info |
     bundle_path = bundle_info[:path]
     is_newer = find_newer( bundle_path, newer_than )
     return true if is_newer
   end
   return false
  end
  
  def print_stat( package_name, dst_size, jsc_size, gz_size )
    percent = 'n/a'
    if dst_size > 0
      percent1 = (100*(jsc_size/dst_size.to_f)).to_i.to_s + '%'
      percent2 = (100*(gz_size/dst_size.to_f)).to_i.to_s + '%'
    else
      percent1 = '-'
      percent2 = '-'
    end
    if jsc_size == -1
      jsc_size = ''
      percent1 = ''
    end
    if gz_size == -1
      gz_size  = ''
      percent2 = ''
    end
    @logger.log(  "#{package_name.ljust(30).gsub(' ','.')}: #{dst_size.to_s.rjust(9)} | #{jsc_size.to_s.rjust(6)} #{percent1.rjust(4)} | #{gz_size.to_s.rjust(6)} #{percent2.rjust(4)}" )
  end
  
  def flush
    @jscompress.free_indexes
  end
end

