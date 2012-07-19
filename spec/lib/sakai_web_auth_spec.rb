require 'spec_helper'
require 'yaml'

describe SakaiWeb::Client do

	describe "#new" do
		it "should create a new SakaiWeb::Client instance" do
			SakaiWeb::Client.new.should be_an_instance_of(SakaiWeb::Client)
		end
		it "Creates an unauthorized SakaiWeb::Client" do
			client = SakaiWeb::Client.new
			client.user.should be_nil
			client.pass.should be_nil
			client.auth_url.should be_nil
		end
	end

	describe "local configuration file" do
		it "should have a default config file location" do
			client = SakaiWeb::Client.new
			client.config_file.should eql( Dir.home + "/.sakai_web_config.yml" )
		end
		it "should accept a new config file location" do
			client = SakaiWeb::Client.new( {:config_file => Dir.home + "Desktop/.sakai_web_config.yml"} )
			client.config_file.should eql( Dir.home + "Desktop/.sakai_web_config.yml" )
		end
	end

	describe "#login" do
		before(:all) do
			@config = YAML.load_file(Dir.home + "/.sakai_web_config.yml");
			@client = SakaiWeb::Client.new
		end

		it "should have a valid url for logging in" do
			expect{ @client.login }.to_not raise_error(ArgumentError, "No login wsdl URL supplied.")
		end
		it "should accept a login url override" do
			expect{ @client.login(@config[:auth_wsdl]) }.to_not raise_error(ArgumentError, "No login wsdl URL supplied.")
			@client.auth_url.should eql(@config[:auth_wsdl])
		end
		it "should need a user and password" do
			expect { @client.login( @config[:auth_wsdl], {:user => @config[:admin], :pass => @config[:pass]} ) }.to_not raise_error(ArgumentError)
			@client.user.should eq(@config[:admin])
			# @client.pass.should eq(config[:pass])
		end
		it "should not have a session set before authentication" do
			client = SakaiWeb::Client.new
			client.session.should be_nil
		end
		it "should get a new session after login" do
			@client.login
			@client.session.should_not be_nil
		end
  #           it "should be able to clusterbust through a load balancer", :focus => true do
  #             client = SakaiWeb::Client.new
  #             expect { client.login( "https://stage.oncourse.iu.edu/sakai-axis/SakaiLogin.jws?wsdl" ,
  #               {:user => "davpoind_admin", :pass => "oncourse is administrated"}) }.to_not raise_error
  #             expect { client.list_tools_for_site( "SU12-IN-UITS-PRAC-45662", {:service_wsdl => "https://stage.oncourse.iu.edu/sakai-axis/SakaiScript.jws?wsdl"} ) }.to_not raise_error
  #           end
		# it "should be able to establish a session, then make repeated calls to the service"  do
		# 	client = SakaiWeb::Client.new
		# 	expect { client.login( "https://stage.oncourse.iu.edu/sakai-axis/SakaiLogin.jws?wsdl" ,
		# 			{:user => "davpoind_admin", :pass => "oncourse is administrated"}) }.to_not raise_error
		# 	expect {
		# 			3.times do

		# 				2.times do
		# 					client.list_tools_for_site( "SU12-IN-UITS-PRAC-45662",
		# 					{:service_wsdl => "https://stage.oncourse.iu.edu/sakai-axis/SakaiScript.jws?wsdl"} )
		# 					sleep(2)
		# 				end
		# 				sleep(10)
		# 				3.times do
		# 					client.list_tools_for_site( "SU12-IN-UITS-PRAC-45662",
		# 					{:service_wsdl => "https://stage.oncourse.iu.edu/sakai-axis/SakaiScript.jws?wsdl"} )
		# 					sleep(3)
		# 				end
		# 				sleep(10)
		# 			end
		# 		}.to_not raise_error
		# end
	end
	describe "#loggedin?" do
		before(:all) do
			@client = SakaiWeb::Client.new
		end
		it "should fail when there is no session set" do
			@client.should_not be_loggedin
		end
		it "should pass when there is a recent session" do
			@client.login
			@client.should be_loggedin
		end
	end
	describe "#logout", :focus => true do

		it "should take a session and logout"
	end
end
