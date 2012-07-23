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

        # Method used to call the Sakai Web Services login WSDL and establish a new session
        #
        # @return (see #login)
        def get_new_session
            client = Savon::Client.new do
                wsdl.document = auth_url
                wsdl.element_form_default = :unqualified
            end

            begin
                login_response = client.request  :login do |soap|
                    soap.body = {:id => @user, :pw => @pass}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise error.to_s
            rescue Savon::SOAP::Fault => fault
                raise StandardError, "Invalid login credentials."
            rescue Savon::Error => error
                raise error.to_s
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
        # Session will probably stick around, but will be marked inactive immediately.
        #
        # @param session [String] Session identifier from which to log out.
        def logout( session )
            unless @session = session
                raise StandardError, "Session #{session}, is not active."
            end

            client = Savon::Client.new do
                wsdl.document = auth_url
                wsdl.element_form_default = :unqualified
            end

            begin
                logout_response = client.request  :logout do |soap|
                    soap.body = {:id => session.to_s}
                end
            rescue ArgumentError, "Wasabi needs a WSDL document"
                raise StandardError, "Incorrect login url supplied."
            rescue Errno::ECONNREFUSED => error
                raise error.to_s
            rescue Savon::SOAP::Fault => fault
                raise StandardError, "Incorrect session for logout: #{fault.to_s}"
            rescue Savon::Error => error
                raise error.to_s
            end

            unless logout_response.soap_fault?
                @session = nil
            end

        end
    end
end
