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
        def list_services
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

        def list_tools_for_site( site_id )
            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
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

        def get_site_property( site_id, property_name )
            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
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

        def add_property_to_site( site_id, property )
            return false unless get_site_property(site_id, property[:propname])

            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
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

        def find_page_in_site( site_id, page_title )
            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
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

            page_list = Nokogiri::XML.parse(
                            response.to_hash[:get_pages_and_tools_for_site_response][:get_pages_and_tools_for_site_return])
            page_array = Array.new

            page_list.css("pages > page").each do |page|
                page_array << {:title => page.css("page-title").inner_text}
            end

            haystack = page_array
            needle = page_title

            result = haystack.select {|h| h[:title] == needle}

            if result.empty?
                return false
            else
                return true
            end
        end

        def add_page_to_site( site_id, page_title, layout = 0, opts = {} )
            if find_page_in_site( site_id, page_title )
                return true
            end

            config = YAML.load(File.open(@config_file))
            service_wsdl = opts[:service_wsdl] ||= config[:service_wsdl]

            client = Savon::Client.new do |wsdl|
                wsdl.document = service_wsdl
                wsdl.element_form_default = :unqualified
            end

            begin
                response = client.request  :add_new_page_to_site do |soap|
                    soap.body = { :sessionid => @session,
                                            :siteid => site_id,
                                            :pagetitle => page_title,
                                            :layouthints => layout
                                        }
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            rescue Exception => error
                raise puts error
            end

            ( response.to_hash[:add_new_page_to_site_response][:add_new_page_to_site_return] == "success" ) ? true : (return false)

        end

        def remove_page_from_site( site_id, page_title )
            # unless find_page_in_site( site_id, page_title )
            #     raise "Page #{page_title} does not exist in #{site_id}."
            # end

            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
                wsdl.element_form_default = :unqualified
            end
            binding.pry
            begin
                response = client.request  :remove_page_from_site do |soap|
                    soap.body = { :sessionid => @session,
                                            :siteid => site_id,
                                            :pagetitle => page_title
                                        }
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            rescue Exception => error
                raise puts error
            end
            binding.pry

        end

        # Adds a specified tool to a specified site
        #
        # @param [Hash] site hash of site attributes
        # @param [Hash] opts options hash containing
        def add_tool_to_site( site_id, page_title, tool_title, tool_id, layout_hints = "0,0", opts = {} )
            if find_tool_in_site( site_id, tool_id )
                # raise "Tool #{tool_id} already exists in site #{site_id}"
                return true
            end

            # Must have a page added to the site first!
            unless find_page_in_site( site_id, page_title )
                add_page_to_site( site_id, page_title )
            end

            client = Savon::Client.new do |wsdl|
                wsdl.document = @service_wsdl
                wsdl.element_form_default = :unqualified
            end

            begin
                response = client.request  :add_new_tool_to_page do |soap|
                    soap.body = { :sessionid => @session,
                                            :siteid => site_id,
                                            :pagetitle => page_title,
                                            :tooltitle => tool_title,
                                            :toolid => tool_id,
                                            :layouthints => layout_hints
                                        }
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect wsdl url supplied."
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            rescue Exception => error
                raise puts error
            end

            ( response.to_hash[:add_new_tool_to_page_response][:add_new_tool_to_page_return] == "success" ) ? true : (return false)
        end
    end
end
