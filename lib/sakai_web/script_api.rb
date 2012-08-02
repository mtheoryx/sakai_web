require 'savon'
require 'yaml'
require 'nokogiri'

Savon.configure do |c|
  c.log = false
  c.pretty_print_xml = true
end
HTTPI.log = false

module SakaiWeb
    # SakaiScript.jws wrapper methods
    #
    # @author (see SakaiWeb)
    module ScriptApi

        # List all the services available in the WSDL
        #
        # @return [Array] Array of actions than can be used
        def list_services
            client = prepare_request( @service_wsdl )

            actions = do_request_and_handle_errors do
                client.wsdl.soap_actions
            end

            return actions unless actions.length < 1
        end

        # Show all the current tools that are added to all of a sites pages
        #
        # @param site_id [String] The site identifier for a sakai site
        #
        # @return [Array] Returns and array of hashes containing tool ids and tool titles.
        def list_tools_for_site( site_id )
            client = prepare_request( @service_wsdl )

            begin
                response = client.request  :get_pages_and_tools_for_site do |soap|
                    soap.body = {:sessionid => @session, :siteid => site_id}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise "Server doesn't seem to be there: #{error.to_s}"
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            rescue
            end


            tool_list = Nokogiri::XML.parse(
                            response.to_hash[:get_pages_and_tools_for_site_response][:get_pages_and_tools_for_site_return])
            tool_array = Array.new

            tool_list.css("tools > tool").each do |tool|
                tool_array << {:title => tool.css("tool-title").inner_text, :id => tool.css("tool-id").inner_text}
            end

            return tool_array
        end

        # Checks if a site property is already set in a site
        #
        # @param site_id [String]
        # @param property_name [String]
        #
        # @return [Boolean] Returns true if that property is already set, false if it can't be found.
        def get_site_property( site_id, property_name )
            client = prepare_request( @service_wsdl )

            response = do_request_and_handle_errors do
                client.request  :get_site_property do |soap|
                    soap.body = {:sessionid => @session, :siteid => site_id, :propname => property_name}
                end
            end

            result = response.to_hash[:get_site_property_response][:get_site_property_return]

            (result.kind_of? Hash) ? (return false) : (return true)
        end

        # Add a site property key/value pair to a site
        #
        # @param site_id [String]
        # @param property [Hash] property key/value pair
        #
        # @options property [String] :propname
        # @options property [String] :propvalue
        #
        # @return [Boolean] Returns true if the property was added, false if it was not added.
        def add_property_to_site( site_id, property )
            return true if get_site_property(site_id, property[:propname])
            client = prepare_request( @service_wsdl )

            begin
                response = client.request  :set_site_property do |soap|
                    soap.body = {:sessionid => @session,
                                        :siteid => site_id,
                                        :propname => property[:propname],
                                        :propvalue => property[:propvalue]}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise "Server doesn't seem to be there: #{error.to_s}"
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            end

            (response.to_hash[:set_site_property_response][:set_site_property_return] == "success") ? true : false
        end

        # Searches a site for a tool
        #
        # @param site_id [String]
        # @param tool_id [String]
        #
        # @return [Boolean] Returns true if the tool was found in the site, false if it was not found.
        def find_tool_in_site( site_id, tool_id )
            haystack = list_tools_for_site( site_id )
            needle = tool_id

            result = haystack.select {|h| h[:id] == needle}

            (result.empty?) ? false : (return true)
        end

        # Searches a site for a page
        #
        # @param site_id [String]
        # @param page_title [String]
        #
        # @return [Boolean] Returns true if the page was found in the site, false if the page cannot be found
        def find_page_in_site( site_id, page_title )
            client = prepare_request( @service_wsdl )

            # response = do_request_and_handle_errors do
            #     client.request  :get_pages_and_tools_for_site do |soap|
            #         soap.body = {:sessionid => @session, :siteid => site_id}
            #     end
            # end
            response = client.request  :get_pages_and_tools_for_site do |soap|
                    soap.body = {:sessionid => @session, :siteid => site_id}
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

            (result.empty?) ? false : (return true)
        end

        # Adds a page to a site
        #
        # @param site_id [String]
        # @param page_title [String]
        # @param layout [Int]
        #
        # @return [Boolean] True if operation successful, false if it was not.
        def add_page_to_site( site_id, page_title, layout = 0)
            return true if find_page_in_site( site_id, page_title )

            client = prepare_request( @service_wsdl )

            begin
                response = client.request  :add_new_page_to_site do |soap|
                    soap.body = { :sessionid => @session,
                                            :siteid => site_id,
                                            :pagetitle => page_title,
                                            :layouthints => layout}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise "Server doesn't seem to be there: #{error.to_s}"
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            end

            ( response.to_hash[:add_new_page_to_site_response][:add_new_page_to_site_return] == "success" ) ? true : (return false)
        end

        # Adds a specified tool to a specified site
        #
        # Also checks and creates if a page exists for the tool first.
        #
        # @param site_id [String]
        # @param page_title [String]
        # @param tool_title [String]
        # @param tool_id [String]
        # @param layout_hints [String]
        #
        # @return [Boolean]
        def add_tool_to_site( site_id, page_title, tool_title, tool_id, layout_hints = "0,0")
            return true if find_tool_in_site( site_id, tool_id )

            add_page_to_site( site_id, page_title ) unless find_page_in_site( site_id, page_title )

            client = prepare_request( @service_wsdl )

            begin
                response = client.request  :add_new_tool_to_page do |soap|
                    soap.body = { :sessionid => @session,
                                            :siteid => site_id,
                                            :pagetitle => page_title,
                                            :tooltitle => tool_title,
                                            :toolid => tool_id,
                                            :layouthints => layout_hints}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise "Server doesn't seem to be there: #{error.to_s}"
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            end



            ( response.to_hash[:add_new_tool_to_page_response][:add_new_tool_to_page_return] == "success" ) ? true : (return false)
        end
    end
end
