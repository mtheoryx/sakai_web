require 'yaml'

%w{version auth utilities script_api}.each do |local|
  require "sakai_web/#{local}"
end
# SakaiWeb sakai web services API wrapper
#
# @author David Poindexter <davpoind@iupui.edu>
module SakaiWeb
  # SakaiWeb sakai web services API wrapper
  #
  # @author (see SakaiWeb)
  class Client

    [Auth, Utilities, ScriptApi].each do |inc|
      include inc
    end

    attr_accessor(:user, :pass, :auth_url, :session, :cookie, :config_file)

    # Creates a new instance of SakaiWeb::Client
    #
    # Configuration options can be passed in, or read from a YAML configuration file.
    #
    # @param opts [Hash] opts The configuration options for interracting with the web services.
    def initialize( opts = {} )
      @user = nil
      @pass = nil
      @auth_url = nil
      @session = nil
      @cookie = nil
      @config_file = opts[:config_file] ||= Dir.home + "/.sakai_web_config.yml"
      @config = YAML.load(File.open(@config_file))
      @service_wsdl = @config[:service_wsdl]
    end

  end
end
