require 'json'
require 'set'
require 'httpi'      # <= these gems are already included, so requiring them again would not hurt 
require 'concurrent' # <= but like that you can just require this file to use it elsewhere

class NPM
  attr_reader :name

  URL = "http://registry.npmjs.org/PACKETNAME/latest"

  def initialize(name)
    @name = name
    @all_dependencies = Concurrent::Map.new
    @futures = Concurrent::Map.new
  end

  # getting dependencies
  # main loop, where we check if all futures are resolved
  # after all futures are fulfilled, we don't have requests anymore
  # and that means that all_dependencies hash have them all
  def all_dependencies
    recursive_fetch(self.name)
    while !@futures.keys.empty?
      sleep 0.1
    end
    @all_dependencies.keys - [self.name] # just need to remove initial 
  end

  # we get dependencies here and put it in @all_dependencies hash
  # after that, we can delete future from @futures 
  # we can continue producing futures 
  # if new packet is not in @all_dependencies or @futures maps 
  def recursive_fetch(packet_name)   
    @all_dependencies[packet_name] = NPM.dependencies_for(packet_name)
    @futures.delete(packet_name)
    @all_dependencies[packet_name].each do |dp|
      unless @all_dependencies.keys.include?(dp) || @futures.keys.include?(dp)
        @futures[dp] = Concurrent::Future.execute{ recursive_fetch(dp) }
      end 
    end
  end

  def self.dependencies_for(packet_name)
    request = HTTPI::Request.new
    request.url = self::URL.gsub("PACKETNAME", packet_name)
    response = JSON.parse(HTTPI.get(request).body)
    if response.has_key?('dependencies')
      response['dependencies'].map(&:first)
    else 
      []
    end
  end
end
