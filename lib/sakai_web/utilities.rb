require 'savon'

module SakaiWeb
    # General utilities to DRY up code
    #
    # @author (see SakaiWeb)
    module Utilities
        # Creates and configures a new Savon::Client
        #
        # @param action_wsdl [String] WSDL to prepare the Savon::Client with
        #
        # @return [Savon::Client] Returns a new Savon::Client
        def prepare_request(action_wsdl)
            client = Savon::Client.new do |wsdl|
                wsdl.document = action_wsdl
                wsdl.element_form_default = :unqualified
            end

            return client
        end

        # Accepts code as a block and does the exception handling all in one place.
        #
        # We don't handle ALL exceptions because we don't know how to.
        #
        # But there are a few that we can predict, catch those, and at least explain what happened.
        #
        # @raise [StandardError] Problem with the provided WSDL url
        # @raise [Errno::ECONNREFUSED] This happens if the server is down, or can't be reached, or doesn't exist.
        def do_request_and_handle_errors
            begin
                yield
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise "Server doesn't seem to be there: #{error.to_s}"
            rescue Savon::SOAP::Fault => fault
                raise fault.to_s
            end
        end
    end
end
