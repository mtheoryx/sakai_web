require 'spec_helper'
require 'yaml'

describe "SakaiWeb webservice authentication" do
	
	config = YAML.load_file("config.yaml");
	
	before(:all) do
		@base_url = "http://localhost:8080/sakai-axis/"
		@login_wsdl = "SakaiLogin.jws?wsdl"
		@service = "getSiteTitle"
		@admin = config["admin"]
		@pass = config["passs"]
		@user = config["user"]
		@site_id = config["site_id"]
	end
	it "should be the correct login url" do
		SakaiWeb.get(@sample_service, @sample_site_id, {:admin => @admin, :pass => @pass} )
		puts @admin
	end
	it "should have a user and password supplied"
	it "should return error for not logging in"
	it "should return an error for an invalid auth"
	it "should return a session id if you log in correctly"
end

describe "Webservice WSDL exists" do
	it "should give an error if you point to a WSDL that isn't there"
	it "WSDL should exist"
end

describe "Webservice service requested should exist" do
	it "should give an error if you point to a service that doesn't exist"
	it "WSDL should contain that requested service"
end

# Might move this off to separate tests
# for each of the services needed right now
# describe "Webservice request sending" do
# end