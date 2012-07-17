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
			# binding.pry
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
		it "should be able to clusterbust through a load balancer" do
			pending "Need access to cluster to test this"
			client = SakaiWeb::Client.new
			expect { client.login( "https://oncourse.iu.edu/sakai-axis/SakaiLogin.jws?wsdl" ,
					{:user => "", :pass => ""}) }.to_not raise_error
			# @TODO: call a basic "get" method to make sure the cookies are being handled
		end
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
end
