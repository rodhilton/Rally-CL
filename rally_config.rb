class RallyConfig
  attr_accessor :username, :password, :workspace
  
  require 'fileutils'
  require 'rubygems'
  require 'rally_rest_api'
  
  def initialize
    @config_filename = File.join(File.expand_path(ENV['HOME'] || ENV['USERPROFILE']), ".rallycl.yaml")
  end
  
  def connection
    if username.nil?
      puts "Username not set.  To set, use rally config username <username>"
      Process.exit
    end
    
    if password.nil?
      puts "Password not set.  To set, use rally config password <password>"
      Process.exit
    end
    
     RallyRestAPI.new(:username => username, :password => password)
  end
  
  def lookup_artifact_type(formatted_id)
    prefix = /([A-Za-z]+)\d+/.match(formatted_id)[1]
    prefixes = load_attribute("prefixes") || {}
    type = prefixes[prefix]
    if type.nil?
      puts "Prefix #{prefix} not understood.  To set, use rally config prefix <prefix> <type>"
      Process.exit
    else
      return type.to_sym
    end
  end
  
  def set_prefix(prefix, type)
    prefixes = load_attribute("prefixes") || {}
    prefixes[prefix] = type
    save_attribute("prefixes", prefixes)
  end
  
  def username=(username)
    save_attribute("username", username)
    clear_attribute("workspace")
  end
  
  def username
    load_attribute("username")
  end
  
  def password=(password)
    save_attribute("password", password)
  end
  
  def password
    load_attribute("password")
  end
  
  def workspace
    workspace = load_attribute("workspace")
    if workspace.nil?
      puts "Workspace not set.  To set, use rally config workspace '<workspace name>' (To list them, use rally config workspace)"
      Process.exit
    else
      return workspace
    end
  end
  
  def workspace=(workspace)
    save_attribute("workspace", workspace)
  end
  
  def load_attribute(name)
    object = {}
    begin
      File.open(@config_filename) do |f|  
        object = Marshal.load(f)  
      end
    rescue
    end

    object[name]
  end
  
  def clear_attribute(name)
    save_attribute(name, nil)
  end
  
  def save_attribute(name, value)
    object = {}
    begin
      File.open(@config_filename) do |f|  
        object = Marshal.load(f)  
      end
    rescue
    end

    object[name] = value
    
    File.open(@config_filename, 'w+') do |f|  
      Marshal.dump(object, f)  
    end
  end
end

class RallyConfigModule < RallyModule

  RALLY_CONFIG = RallyConfig.new

  def self.module_name
    "config"
  end
  
  def self.commands
    ["username", "password", "workspace", "prefix"]
  end
  
  def prefix(opts)
    prefix = opts[0]
    type = opts[1]
    if prefix.nil? or type.nil?
      puts "To set prefix, use rally config prefix <prefix> <type>.  Types include defect, task, hierarchical_requirement"
    else
      RALLY_CONFIG.set_prefix(prefix, type)
      puts "Set prefix #{prefix} to #{type}"
    end
  end
  
  def workspace(opts)
    if(opts[0].nil?)
      workspaces = RALLY_CONFIG.connection.user.subscription.workspaces
      puts "Possible Workspaces:"
      workspaces.each do |workspace|
        puts "  '#{workspace.name}'"
      end
      puts "To set, use rally config workspace '<workspace name>'"
    else
      new_workspace = opts[0]
      workspace = RALLY_CONFIG.connection.user.subscription.workspaces.detect{|workspace| workspace.name == new_workspace}
      if workspace.nil?
        puts "Invalid workspace"
      else
        RALLY_CONFIG.workspace=workspace
        puts "Set workspace to '#{new_workspace}'"
      end
    end
  end
  
  def username(username_opts)
    if(username_opts[0].nil?)
      puts "Username is: #{RALLY_CONFIG.username}"
    else
      new_username = username_opts[0]
      RALLY_CONFIG.username=new_username
      puts "Set username to #{new_username}"
    end
  end
  
  def password(opts)
    if(opts[0].nil?)
      puts "Password is: #{RALLY_CONFIG.password}"
    else
      new_password = opts[0]
      RALLY_CONFIG.password=new_password
      puts "Set password to #{new_password}"
    end
  end
  
end