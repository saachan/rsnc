# -* coding: UTF-8 -*-
###
  # Riassence Core -- http://rsence.org/
  #
  # Copyright (C) 2008 Juha-Jarmo Heinonen <jjh@riassence.com>
  #
  # This file is part of Riassence Core.
  #
  # Riassence Core is free software: you can redistribute it and/or modify
  # it under the terms of the GNU General Public License as published by
  # the Free Software Foundation, either version 3 of the License, or
  # (at your option) any later version.
  #
  # Riassence Core is distributed in the hope that it will be useful,
  # but WITHOUT ANY WARRANTY; without even the implied warranty of
  # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  # GNU General Public License for more details.
  #
  # You should have received a copy of the GNU General Public License
  # along with this program.  If not, see <http://www.gnu.org/licenses/>.
  #
  ###

require 'rubygems'
require 'rack'

## Paths for log and pid files
PIDPATH = File.join(SERVER_PATH,'var','run')
LOGPATH = File.join(SERVER_PATH,'var','log')

## Client by default is "server/client"
if ARGV.include?('--client-path')
  CLIENT_PATH = ARGV[ARGV.index('--client-path')+1]
else
  client_path_test1 = File.expand_path( File.join( SERVER_PATH, 'client' ) )
  client_path_test2 = File.expand_path( File.join( SERVER_PATH, '..', 'client' ) )
  if File.exist?(client_path_test1)
    CLIENT_PATH = client_path_test1
  elsif File.exist?(client_path_test2)
    CLIENT_PATH = client_path_test2
  else
    warn "WARNING: CLIENT_PATH: #{CLIENT_PATH.inspect} not found in standard locations (#{client_path_test1.inspect} or #{client_path_test2.inspect})"
  end
end

## Global configuration hash
$config = {
  
  ## The base_url specifies the prefix for all default http responders, except servlets.
  ## NOTE: the default index_html servlet is aware of this parameter.
  :base_url => '/',
  
  ## This setting should be on, until Rack supports chunked transfers (and as such, transfer encodings for gzip)
  :no_gzip => false,
  
  ## Enabling this appends all msg.reply call output to stdout
  :trace   => ARGV.include?('--trace-js'),
  
  ## Path to the server root (containing lib, rsrc etc..)
  :dir_root    => SERVER_PATH,
  
  ## Index html parameters (to replace the index with your own etc)
  :index_html => {
    :index_tmpl => 'tmpl/index.html', # template file path relative to the plugin dir
    :deps       => []                 # list of js src's to pre-load 
  },
  
  :main_plugin => {
    :bg_color              => '#ffffff', # the color of the web page after loading is done
    :server_poll_interval  => 10000      # how many milliseconds to wait before doing an idle poll
  },
  
  ## Path to the client root (containing js and themes dirs)
  :client_root => CLIENT_PATH,
  
  ## Switches on debug-mode:
  ##  - Generates more output
  ##  - Each time /hello is post-requested:
  ##    - Plugins are reloaded from source 
  ##    - GZFiles are reloaded (if more recent than in memory)
  :debug_mode  => (ARGV.include?('-d') or ARGV.include?('--debug')),
  
  ## Web server-related settings:
  :http_server  => {
    
    ## HTTP Port number:
    :port           => ARGV.include?('--port')?(ARGV[ARGV.index('--port')+1].to_i):8001,
    
    ## Bind this ip address ('0.0.0.0' means all)
    :bind_address   => ARGV.include?('--addr')?(ARGV[ARGV.index('--addr')+1]):'0.0.0.0',
    
    ## Rack handler to use, defaults to thin
    :rack_require   => ARGV.include?('--server')?(ARGV[ARGV.index('--server')+1]):'thin',
    :rack_handler   => nil # automatic
  },
  
  ## When disabled, tries to prevent all request caching
  :cache_maximize => false,
  
  ## When cache_maximize is enabled,
  ## this is the time (in seconds) the cached content will expire in
  :cache_expire   => 14515200,
  
  ## Client-related paths (fileserve)
  :client_parts => {
    
    ## The paths FileServe uses to load client js, css and html templates
    :js      => File.join( CLIENT_PATH, 'js'      ),
    :themes  => File.join( CLIENT_PATH, 'themes'  )
  },
  
  ## Old param, essentially always the same as SERVER_PATH
  :sys_path     => SERVER_PATH,
  
  ## Paths to scan for available plugins
  :plugin_paths    => [
    File.join( SERVER_PATH, 'plugins' )
    #File.join( PATH_TO_ALT_PLUGINS, 'plugins' )
  ],
  
  ## The global Transporter instance will be bound to:
  :transporter => nil,
  
  ## The global IndexHtml instance will be bound to:
  :indexhtml   => nil,
  
  ## The global FileCache instance will be bound to:
  :filecache   => nil,
  
  ## The global FileServe instance will be bound to:
  :fileserve   => nil,
  
  ## The global TicketServe instance will be bound to:
  :ticketserve => nil,
  
  ## The global Broker instance will be bound to:
  :broker => nil,
  
  ## The global SessionManager instance will be bound to:
  :sessionmanager => nil,
  
  ## The global PluginManager instance will be bound to:
  :plugins => nil,
  
  ## Tracking-related settings (allows storing what the user does from the server's point of view)
  :tracking => {
    :enabled => ARGV.include?('--enable-tracking')
  },
  
  
  ## Transporter settings:
  :transporter_conf => {
    
    ## The HApplication priority of the client, when actively polling.
    :client_poll_priority => 60,
    
    ## Message strings
    :messages => {
      
      # If the client fails on javascript, display this:
      :client_error => {
        :title => 'ClientError',
        :descr => 'Your web browser has encountered an javascript error.[[br /]]Please reload the page to continue.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the filecache fails, display this:
      :filecache_error => {
        :title => 'Transporter::FileCacheError',
        :descr => 'FileCache encountered an error.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :plugins_rescan_error => {
        :title => 'Transporter::PluginsRescanError',
        :descr => 'The initialization of a plugin failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :valuemanager_xhr_error => {
        :title => 'Transporter::ValueManagerXHRError',
        :descr => 'The parsing of the syncvalues xml data failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :valuemanager_validate_error => {
        :title => 'Transporter::ValueManagerValidateError',
        :descr => 'The value validation process failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :valuemanager_sync_client_error => {
        :title => 'Transporter::ValueManagerSyncClientError',
        :descr => 'The value syncronization to the client failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :plugin_delegate_restore_ses_error => {
        :title => 'Transporter::PluginDelegateRestoreSesError',
        :descr => 'The plugin delegation process for restore_ses failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :plugin_delegate_init_ses_error => {
        :title => 'Transporter::PluginDelegateInitSesError',
        :descr => 'The plugin delegation process for init_ses failed.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      },
      
      # If the plugins rescan fails, display this:
      :plugin_idle_error => {
        :title => 'Transporter::PluginIdleError',
        :descr => 'The idle event failed for a plugin.[[br /]]Please reload the page to retry.[[br /]]Error encountered:[[br /]]',
        :uri   => '/'
      }
    }
  },
  
  ## IndexHtml settings:
  :indexhtml_conf => {
    ## The initial index.html page <title>
    :loading_title  => 'Loading...',
    
    ## The initialized html page <title>
    :loaded_title   => 'Ready',
  },
  
  ## Session-related settings
  :session_conf => {
    
    :mysql_backend => true,
    
    :session_cookies => true,
    
    ## The comment string in the session cookie
    :ses_cookie_comment => "Riassence Core session key (just for your convenience)",
    
    ## Disposable keys, when enabled, changes the session id on each xhr
    :disposable_keys    => true,
    
    ## Timeout controls how long a session is valid
    :timeout_secs       => 15*60, # 15 minutes
    
    ## Key length controls the length of the random-part of the key.
    ## The total length is actually key length + 12 bytes, because
    ## the uniqueness part is 12 bytes long
    :key_length         => 64,
    
    ## Cookie keys are this many times longer than xhr keys
    :cookie_key_multiplier => 3,
    
    ## The amount of pre-generated keys to keep
    ## Tweaking this might affect performance
    :buffer_size        => 600,
    
    ## When enabled, deletes all old sessions upon server startup
    :reset_sessions     => (ARGV.include?('--reset-sessions=true') or ARGV.include?('--reset-sessions')),
    
    ## Message strings
    :messages => {
      
      # if the session is invalid for one reason or another, display this:
      :invalid_session => {
        :title => 'Invalid Session',
        :descr => 'Your session is invalid. Please reload the page to continue.',
        :uri   => '/'
      }
    }
    
  },
  
  ## Database configuration
  :database => {
    
    # root_setup should ideally have permissions
    # to create the auth_setup account and database,
    # but if the access fails, it'll fall back to
    # auth_setup, if it's created manually
    :root_setup => {
      :host => '127.0.0.1', # try '127.0.0.1' if this fails with your mysql configuration
      :user => 'root',
      :pass => '',
      :db   => 'mysql'
    },
    
    # auth_setup is the mysql connection rsence uses
    # to handle session tables. It's obligatory.
    :auth_setup => {
      :host => '127.0.0.1',
      :user => 'rsence',
      :pass => 'bbJNhmtwtOBu6',
      :db   => 'rsence'
    }
  
  },
  
  ## ValueManager settings
  :values_conf => {
    ## Key length controls the length of the random-part of the key.
    ## The total length is actually key length + 12 bytes, because
    ## the uniqueness part is 12 bytes long
    :key_length    => 20, # 32 bytes long value keys
    
    ## The amount of pre-generated keys to keep
    ## Tweaking this might affect performance
    :buffer_size        => 600,
    
    ## Disposable keys, when enabled, changes the value id on each session restoration
    :disposable_keys    => true,
    
    ## Message strings
    :messages => {
      
      # this message is for version mismatches in hsyncvalues
      :version_mismatch => {
        :title => 'Client/Server Mismatch Error',
        :descr => 'The client and server are incompatible, reason: version mismatch. Please contact your system administrator.',
        :uri   => '/'
      }
    }
  },
  
  :daemon => {
    :pid_fn => File.join(PIDPATH, "rsence.pid"),
    :log_fn => File.join(LOGPATH, "rsence")
  },
  
  :broker_urls => {}
  
}

## Paths of server libraries
LIB_PATHS  = [
  #File.join( SERVER_PATH, 'lib' ) ## already included in launch.rb; override this one in local config, if needed
]

## Create default local configuratation override file, if it does not exist:
local_config_file_path = File.join(SERVER_PATH,'conf','local_conf.rb')


if File.exist?(local_config_file_path)
  require local_config_file_path[0..-4]
elsif ARGV.include?('--config')
  conf_file = ARGV[ARGV.index('--config')+1]
  if conf_file[0].chr != '/'
    conf_file = File.join( Dir.pwd, conf_file )
  end
  if conf_file[-3..-1] != '.rb'
    warn "WARNING: Only ruby configuration files are supported for now."
    warn "         Future versions might include YAML support."
    warn "      -> #{conf_file} ignored."
  elsif File.exist?( conf_file )
    # strip the '.rb' suffix
    conf_file = conf_file[0..-4]
    require conf_file
  else
    warn "ERROR: Configuration file #{conf_file.inspect} not found."
    exit
  end
else
  puts "NOTE:  Local configuration file #{local_config_file_path.inspect}"
  puts "       does not exist, creating a default one."
  puts "Please answer the following questions, blank lines equal to the default in brackets:"
  require 'conf/wizard'
  conf_wizard = ConfigWizard.new
  local_config_data = conf_wizard.run( local_config_file_path )
end

unless $config[:database].has_key?(:ses_db)
  warn "WARNING: The database is not configured with a :ses_db url."
  warn "         You are advised to convert the :root_setup and :auth_setup keys of"
  warn "         $config[:database] to the new url format."
  db_auth = $config[:database][:auth_setup]
  $config[:database][:ses_db] = "mysql://#{db_auth[:user]}:#{db_auth[:pass]}@#{db_auth[:host]}:#{db_auth[:port]}/#{db_auth[:db]}"
  warn "      -> Performed automatic conversion of :auth_setup as"
  warn "         $config[:database][:ses_db] = #{$config[:database][:ses_db].inspect}"
end



## Broker configuration
## WARNING: Don't rely on this as-is yet. The naming conventions might still change.

## POST-requests

# The default listener address of cookie-less transporter requests
unless $config[:broker_urls].has_key?(:x)
  $config[:broker_urls][:x]     = File.join($config[:base_url],'x')
end

# The default listener address of cookie-enabled transporter requests
unless $config[:broker_urls].has_key?(:hello)
  $config[:broker_urls][:hello] = File.join($config[:base_url],'hello')
end

# The default listener address of SOAP -requests
unless $config[:broker_urls].has_key?(:soap)
  $config[:broker_urls][:soap] = File.join($config[:base_url],'SOAP')
end

# The default listener address of file uploads
unless $config[:broker_urls].has_key?(:u)
  $config[:broker_urls][:u] = File.join($config[:base_url],'U')
end


## GET-requests

# The default address of built javascript and theme packages
unless $config[:broker_urls].has_key?(:h)
  $config[:broker_urls][:h] = File.join($config[:base_url],'H/')
end

# The default address of the ticketserve :img -category
unless $config[:broker_urls].has_key?(:i)
  $config[:broker_urls][:i] = File.join($config[:base_url],'i/')
end

# The default address of the ticketserve :rsrc -category
unless $config[:broker_urls].has_key?(:d)
  $config[:broker_urls][:d] = File.join($config[:base_url],'d/')
end

# The default address of the ticketserve :file -category
unless $config[:broker_urls].has_key?(:f)
  $config[:broker_urls][:f] = File.join($config[:base_url],'f/')
end

# The default address of the ticketserve :blobobj -category
unless $config[:broker_urls].has_key?(:b)
  $config[:broker_urls][:b] = File.join($config[:base_url],'b/')
end

# The default address of the favicon
unless $config[:broker_urls].has_key?(:favicon)
  $config[:broker_urls][:favicon] = File.join($config[:base_url],'favicon.ico')
end

# The default address of the "empty" iframe of uploader
unless $config[:broker_urls].has_key?(:uploader_iframe)
  $config[:broker_urls][:uploader_iframe] = File.join($config[:base_url],'U/iframe_html')
end


# The default address of the index_html plugin
unless $config[:indexhtml_conf].has_key?(:respond_address)
  $config[:indexhtml_conf][:respond_address] = File.join($config[:base_url])
end


## Uses the lib paths as search paths
LIB_PATHS.each do |lib_path|
  $LOAD_PATH << lib_path
end

unless File.exist?(CLIENT_PATH)
  $stderr.write("ERROR: CLIENT_PATH: #{CLIENT_PATH.inspect} does not exist!\n")
  $stderr.write("Unable to continue; exit.\n")
  exit
end
