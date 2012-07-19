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
            @service_wsdl = opts[:service_wsdl] ||= config[:service_wsdl]

            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
                wsdl.element_form_default = :unqualified
            end

            begin
                actions = client.wsdl.soap_actions
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Exception => error
                raise error.to_s
            end

            return actions unless actions.length < 1
        end

        def list_tools_for_site( site_id, opts = {} )
            config = YAML.load(File.open(@config_file))
            service_wsdl = opts[:service_wsdl] ||= config[:service_wsdl]

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
            rescue Exception => error
                raise error.to_s
            end

            tool_list = Nokogiri::XML.parse(
                            response.to_hash[:get_pages_and_tools_for_site_response][:get_pages_and_tools_for_site_return])
            tool_array = Array.new

            tool_list.css("tools > tool").each do |tool|
                tool_array << {:title => tool.css("tool-title").inner_text, :id => tool.css("tool-id").inner_text}
            end

            return tool_array
        end

        def get_site_property( site_id, property_name, opts = {} )
            config = YAML.load(File.open(@config_file))
            service_wsdl = opts[:service_wsdl] ||= config[:service_wsdl]

            client = Savon::Client.new do |wsdl|
                wsdl.document = service_wsdl
                wsdl.element_form_default = :unqualified
            end

            begin
                response = client.request  :get_site_property do |soap|
                    soap.body = {:sessionid => @session, :siteid => site_id, :propname => property_name}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Savon::SOAP::Fault => fault
                raise StandardError, "Site ID cannot be found."
            rescue Exception => error
                raise error.to_s
            end

            result = response.to_hash[:get_site_property_response][:get_site_property_return]

            (result.kind_of? Hash) ? (return false) : (return true)
        end

        def add_property_to_site( site_id, property, opts = {} )
            return false unless get_site_property(site_id, property[:propname])

            config = YAML.load(File.open(@config_file))
            service_wsdl = opts[:service_wsdl] ||= config[:service_wsdl]

            client = Savon::Client.new do |wsdl|
                wsdl.document = service_wsdl
                wsdl.element_form_default = :unqualified
            end

            begin
                response = client.request  :set_site_property do |soap|
                    soap.body = {:sessionid => @session,
                                        :siteid => site_id,
                                        :propname => property[:propname],
                                        :propvalue => property[:propvalue]}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            rescue Exception => error
                raise puts error
            end

            (response.to_hash[:set_site_property_response][:set_site_property_return] == "success") ? false : true
        end

        def find_tool_in_site( site_id, tool_id )
            haystack = list_tools_for_site( site_id )
            needle = tool_id

            result = haystack.select {|h| h[:id] == needle}

            (result.empty?) ? false : (return true)
        end


    end
end
