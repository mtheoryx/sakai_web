require "sakai_web/version"
require "sakai_web/sakai_web_api"

module SakaiWeb
	def self.get( service, data, auth )
		SakaiWebApi.new.get(service, data, auth)
	end
end
