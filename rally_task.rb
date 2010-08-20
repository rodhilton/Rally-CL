class RallyTaskModule < RallyModule
  require 'rubygems'
  require 'rally_rest_api'
  require 'colored'
  require 'pp'
  require 'date'

  RALLY_CONFIG = RallyConfig.new

  def initialize
    @rally_config = RallyConfig.new
    @artifact_fetcher = RallyArtifactFetcher.new
  end

  def self.module_name
    "task"
  end
  
  def default(show_opts)
    formatted_id = show_opts[0]
    artifact = @artifact_fetcher.fetch(formatted_id)
    if artifact.nil? or artifact.tasks.size <= 0
      puts "No tasks found"
    else
      show_tasks(artifact)
    end
  end
  
  def show_tasks(artifact)
    max_statelen = 0
    artifact.tasks.each do |task|
      if task.state.length > max_statelen
        max_statelen = task.state.length
      end
    end
    
    artifact.tasks.each do |task|
      diff = max_statelen - task.state.length
      print " " * diff
      print " #{task.state} ".white_on_red.bold
      print " "
      print task.name
      print "\n"
    end
  end
  
end