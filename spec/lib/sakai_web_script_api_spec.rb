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
  before(:all) do
    @client = SakaiWeb::Client.new
    @client.login
  end
  it "should require a site id" do
    expect { @client.list_tools_for_site }.to raise_error ArgumentError
    expect { @client.list_tools_for_site("SU12-IN-UITS-PRAC-45662") }.to_not raise_error ArgumentError
  end
  it "should return a list of tools for a given site" do
    pending "Format the list better"
    @client.list_tools_for_site("03eff8a7-cbae-4daa-9387-c06c05cf5e13").should_not be_nil
  end
  it "should throw an error if the site doesn't exist" do
    expect { @client.list_tools_for_site("03eff8a7-cbae-4daa-9387-c06c05XXXXXX") }.to raise_error
  end
end

describe "#find_tool_in_site" do
  it "should require a site id"
  it "should require a tool id"
  it "should return false when the tool is not found"
  it "should return true when the tool is found"
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

describe "#add_property_to_site" do
  it "should require a site id"
  it "should require a property key/value pair"
  it "should see if the property already exists"
  it "should not set an identical property if it exists"
  it "should set the requested property on the site"
  it "should verify that the property was set on the site"
  it "should fail if the verification of setting the property fails"
  it "should pass if the verification of setting the property passes"
end
end
