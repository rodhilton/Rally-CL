class RallyArtifactFetcher
  def initialize
    @rally_config = RallyConfig.new
  end
  
  def fetch(formatted_id)
    query_result = @rally_config.connection.find(@rally_config.lookup_artifact_type(formatted_id), :workspace=> @rally_config.workspace, :fetch=>true) { equal :formatted_id, formatted_id }
    if query_result.results.length == 0
      return nil
    else
      return query_result.first
    end
  end
end

class RallyShowModule < RallyModule
  require 'rubygems'
  require 'rally_rest_api'
  require 'colored'
  require 'pp'

  RALLY_CONFIG = RallyConfig.new

  def initialize
    @artifact_fetcher = RallyArtifactFetcher.new
  end

  def self.module_name
    "show"
  end
  
  def default(show_opts)
    formatted_id = show_opts[0]
    artifact = @artifact_fetcher.fetch(formatted_id)
    if artifact.nil?
      puts "No artifact found"
    else
      show_artifact(artifact)
    end
  end
  
  def show_artifact(artifact)
    elements = artifact.elements.keys.collect{|e| e.to_s}.sort
    max_label_length = elements.collect{|e| e.length}.max
    elements.each do |key|
      value = artifact.elements[key.to_sym]
      unless value.nil?
        unless value.is_a?(RestObject) and value.name.nil? or value.is_a?(Array)
          if value.is_a?(RestObject) and not value.formatted_i_d.nil?
            print_line(titleify(key), "#{value} (#{value.formatted_i_d.bold})", max_label_length)   
          else
            print_line(titleify(key), value, max_label_length)      
          end
        end
      end
    end
  end
  
  def titleify(title) 
    title.to_s.gsub("_"," ").gsub(/\b\w/){$&.upcase}
  end
  
  def print_line(label, value, max_label_length)
    spacing = max_label_length - label.length
    print " "*(spacing+1)
    print " #{label}: ".white_on_red.bold
    print " "
    print value
    print "\n"
  end
  
end