require 'spec_helper'
require 'yaml'

describe SakaiWeb::ScriptApi do
  before(:all) do
      @client = SakaiWeb::Client.new
      @client.login
  end

  describe "#list_services" do
    it "should give a list of available services to use" do
      @client.list_services.should_not be_nil
    end
  end

describe "#list_tools_for_site" do

  it "should require a site id" do
    expect { @client.list_tools_for_site }.to raise_error ArgumentError
    expect { @client.list_tools_for_site("SU12-IN-UITS-PRAC-45662") }.to_not raise_error ArgumentError
  end
  it "should return a list of tools for a given site" do
    @client.list_tools_for_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13").should_not be_nil
    @client.list_tools_for_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13").should be_instance_of Array
  end
  it "should throw an error if the site doesn't exist" do
    expect { @client.list_tools_for_site("03eff8a7-cbae-4daa-9387-c06c05XXXXXX") }.to raise_error
  end
end

describe "#get_site_property" do
  it "should expect a site property name" do
    expect{ @client.get_site_property }.to raise_error ArgumentError
  end
  it "should expect a site id" do
    expect{ @client.get_site_property("not.real.property") }.to raise_error ArgumentError
  end
  it "should return false if property does not exist" do
    @client.get_site_property("03eff8a7-cbae-4daa-9387-c06c05cf5e13", "not.real.property").should be_false
  end
  it "should return the value if property does exist" do
    @client.get_site_property("03eff8a7-cbae-4daa-9387-c06c05cf5e13", "contact-name").should_not be_false
  end
end

describe "#add_property_to_site" do
  it "should require a site id" do
    expect{ @client.add_property_to_site }.to raise_error ArgumentError
  end
  it "should require a property key/value pair" do
    expect{ @client.add_property_to_site( "03eff8a7-cbae-4daa-9387-c06c05cf5e13" ) }.to raise_error ArgumentError
  end
  it "should not set an identical property if it exists" do
    @client.add_property_to_site( "03eff8a7-cbae-4daa-9387-c06c05cf5e13",
              {:propname => "contact-name", :propvalue => "David Poindexter"} ).should be_false
  end
  it "should set the requested property on the site" do
    expect {@client.add_property_to_site( "03eff8a7-cbae-4daa-9387-c06c05cf5e13",
              {:propname => "site.type.pdp", :propvalue => "true"} )}.to_not raise_error
  end
  it "should now have the correct property" do
    @client.add_property_to_site( "03eff8a7-cbae-4daa-9387-c06c05cf5e13",
              {:propname => "site.type.pdp", :propvalue => "true"} )
    @client.get_site_property("03eff8a7-cbae-4daa-9387-c06c05cf5e13", "site.type.pdp").should_not be_false
  end
end

describe "#find_tool_in_site" do
  it "should require a site id" do
    expect{ @client.find_tool_in_site }.to raise_error ArgumentError
  end
  it "should require a tool id" do
    expect{ @client.find_tool_in_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13") }.to raise_error ArgumentError
  end
  it "should return false when the tool is not found" do
    @client.find_tool_in_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13", "fake.tool.id").should be_false
  end
  it "should return true when the tool is found" do
    @client.find_tool_in_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13", "sakai.iframe.site").should be_true
  end
end

describe "#add_tool_to_site" do
  it "should require a site id"
  it "should require a page title"
  it "should require a tool title"
  it "should require a tool id"
  it "should not already be a tool in the site"
  it "should not add a tool that is already in the site"
  it "should add a tool to the site"
  it "should verify that a tool is added to the site"
  it "should fail if the verification of adding a tool fails"
  it "should pass if the verification of adding a tool to the site succeeds"
end

end
