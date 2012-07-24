require 'savon'
require 'yaml'

Savon.configure do |c|
  c.log = false
  c.pretty_print_xml = true
end
HTTPI.log = false


module SakaiWeb
    # Authentication related methods, such as loggin in, getting a session, logging out, etc
    #
    # @author (see SakaiWeb)
    module Auth

        # Log into the Sakai Web Services
        #
        # If successful, sets the SakaiWeb::Client session attribute for further interractions.
        #
        # @param auth_url [String] The url to the SakaiLogin.jws WSDL
        # @param auth_opts [Hash] Options to override defaults.
        #
        # @option auth_opts [String] :admin Username for authentication
        # @option auth_opts [String] :password Password for authentication
        #
        # @raise [ArgumentError] If there isn't a parameter passed in or config file containing auth values
        #
        # @return [Boolean] returns true if a session was set, false if it was not.
        def login(auth_url = nil, auth_opts = {})
            @session, @cookie = nil

            config = YAML.load( File.open(@config_file) );

            @auth_url = auth_url ||= config[:auth_wsdl]
            raise(ArgumentError, "No login wsdl URL supplied.")if @auth_url.nil?

            @user = auth_opts[:user] ||= config[:admin]
            raise(ArgumentError, "No username supplied.") if @user.nil?

            @pass = auth_opts[:pass] ||= config[:pass]
            raise(ArgumentError, "No password supplied.") if @pass.nil?

            get_new_session
        end

        # Calls the Sakai Web Services login WSDL to establish get a new session identifier
        #
        # @return (see #login)
        def get_new_session
            client = prepare_request(auth_url)

            login_response = do_request_and_handle_errors do
                client.request  :login do |soap|
                    soap.body = {:id => @user, :pw => @pass}
                end
            end

            @session = login_response.to_hash[:login_response][:login_return]

            false unless @session.instance_of? Nori::StringWithAttributes
        end

        # Utility method for determining status of a login session
        #
        # @return (see #login)
        def loggedin?
            @session.nil? ? false : (return true)
        end

        # Calls the Sakai web services login wsdl to log out of a session
        #
        # @param session [String] Session identifier from which to log out.
        #
        # @raise [StandardError] Session parameter is not a valid session in the first place.
        #
        # @return [nil]
        def logout( session )
            unless @session = session
                raise StandardError, "Session #{session}, is not active."
            end

            client = prepare_request(auth_url)

            logout_response = do_request_and_handle_errors do
                client.request  :logout do |soap|
                    soap.body = {:id => session.to_s}
                end
            end

            unless logout_response.soap_fault?
                @session = nil
            end
        end
    end
end
