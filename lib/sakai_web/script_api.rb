require 'savon'
require 'yaml'
require 'nokogiri'

Savon.configure do |c|
  c.log = false
  c.pretty_print_xml = true
end
HTTPI.log = false

module SakaiWeb
  module ScriptApi
        def list_services( opts = {} )
          config = YAML.load(File.open(@config_file))
          @service_wsdl = opts[:service_wsdl] ||= config['service_wsdl']

          client = Savon::Client.new do |wsdl|
            wsdl.document = @service_wsdl
            wsdl.element_form_default = :unqualified
          end

          begin
            actions = client.wsdl.soap_actions
          rescue ArgumentError, "Wasabi needs a WSDL document"
            raise StandardError, "Incorrect wsdl url supplied."
          end

          return actions unless actions.length < 1
        end

        def list_tools_for_site( site_id, opts = {} )
          config = YAML.load(File.open(@config_file))
          service_wsdl = opts[:service_wsdl] ||= config['service_wsdl']

          client = Savon::Client.new do |wsdl|
            wsdl.document = service_wsdl
            wsdl.element_form_default = :unqualified
          end



          begin
            response = client.request  :get_pages_and_tools_for_site do |soap|
              soap.body = {:sessionid => @session, :siteid => site_id}
            end
          rescue ArgumentError, "Wasabi needs a WSDL document"
            raise StandardError, "Incorrect wsdl url supplied."
          rescue Savon::SOAP::Fault => fault
            raise StandardError, "Site ID cannot be found."
          end

          tools = response.to_hash[:get_pages_and_tools_for_site_response][:get_pages_and_tools_for_site_return]
          # binding.pry
          tool_list = Nokogiri::XML.parse(tools)
          # binding.pry
          # Locate the Home page

          # List all the tools on the home page

        end
  end
end
