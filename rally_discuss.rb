class RallyDiscussModule < RallyModule
  require 'rubygems'
  require 'rally_rest_api'
  require 'colored'
  require 'pp'

  RALLY_CONFIG = RallyConfig.new

  def initialize
    @rally_config = RallyConfig.new
    @artifact_fetcher = RallyArtifactFetcher.new
  end

  def self.module_name
    "discuss"
  end
  
  def default(show_opts)
    formatted_id = show_opts[0]
    artifact = @artifact_fetcher.fetch(formatted_id)
    if artifact.nil? or artifact.revision_history.revisions.size < 2
      puts "No history found"
    else
      show_history(artifact)
    end
  end
  
  def show_history(artifact)
    artifact.revision_history.revisions.each do |revision|
      time = DateTime.parse(revision.creation_date)
      time_string = time.strftime("%m/%d/%Y %I:%M%p")
      print " #{time_string} ".white_on_red.bold
      print " "
      print revision.description.strip
      unless revision.user.nil?
        print " (By #{revision.user})"
      end
      print "\n"
    end
  end
  
end