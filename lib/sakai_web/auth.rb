require 'savon'
require 'yaml'

Savon.configure do |c|
  c.log = false
  c.pretty_print_xml = true
end
HTTPI.log = false


module SakaiWeb
	module Auth
		def login(auth_url = nil, auth_opts = {})
			@session = nil
			@cookie = nil

			config = YAML.load( File.open(@config_file) );

			@auth_url = auth_url ||= config[:auth_wsdl]
			if @auth_url.nil?
		      	raise(ArgumentError, "No login wsdl URL supplied.")
		      end

		      @user = auth_opts[:user] ||= config[:admin]
		      if @user.nil?
		      	raise(ArgumentError, "No username supplied.")
		      end

		      @pass = auth_opts[:pass] ||= config[:pass]
		      if @pass.nil?
		      	raise(ArgumentError, "No password supplied.")
		      end

			return get_new_session
		end

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
		    	rescue Errno::ECONNREFUSED
		    		raise
		    	rescue Savon::SOAP::Fault => fault
		    		raise StandardError, "Invalid login credentials."
			rescue Savon::Error => error
		    		raise
		    	end

		    	@session = login_response.to_hash[:login_response][:login_return]

		    	unless @session.instance_of? Nori::StringWithAttributes
		    		return false
		    	end

	    	end

	    	def loggedin?
	    		@session.nil? ? false : (return true)
	    	end

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
