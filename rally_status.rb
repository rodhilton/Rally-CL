class RallyStatusModule < RallyModule
  require 'rubygems'
  require 'rally_rest_api'
  require 'colored'
  require 'pp'

  RALLY_CONFIG = RallyConfig.new

  def initialize
    
  end

  def self.module_name
    "status"
  end
  
  def default(show_opts)
    puts show_opts
  end
  
end