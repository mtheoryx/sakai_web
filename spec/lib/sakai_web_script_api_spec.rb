require 'spec_helper'
require 'yaml'

describe SakaiWeb::ScriptApi do
    before(:all) do
        @client = SakaiWeb::Client.new
        @client.login
        @test_correct_site = "03eff8a7-cbae-4daa-9387-c06c05cf5e13"
        @test_wrong_site = "03eff8a7-cbae-4daa-9387-c06c05XXXXXX"
    end

    describe "#list_services" do
        it "should give a list of available services to use" do
            @client.list_services.should_not be_nil
        end
    end

    describe "#list_tools_for_site" do
        it "should require a site id" do
            expect { @client.list_tools_for_site }.to raise_error ArgumentError
            expect { @client.list_tools_for_site( @test_correct_site ) }.to_not raise_error ArgumentError
        end
        it "should return a list of tools for a given site" do
            @client.list_tools_for_site( @test_correct_site ).should_not be_nil
            @client.list_tools_for_site( @test_correct_site ).should be_instance_of Array
        end
        it "should throw an error if the site doesn't exist" do
            expect { @client.list_tools_for_site( @test_wrong_site ) }.to raise_error
        end
    end

    describe "#get_site_property" do
        it "should expect a site property name" do
            expect{ @client.get_site_property }.to raise_error ArgumentError
        end
        it "should expect a site id" do
            expect{ @client.get_site_property( "not.real.property" ) }.to raise_error ArgumentError
        end
        it "should return false if property does not exist" do
            @client.get_site_property( @test_correct_site, "not.real.property" ).should be_false
        end
        it "should return the value if property does exist" do
            @client.get_site_property( @test_correct_site, "contact-name" ).should_not be_false
        end
    end

    describe "#add_property_to_site" do
        it "should require a site id" do
            expect{ @client.add_property_to_site }.to raise_error ArgumentError
        end
        it "should require a property key/value pair" do
            expect{ @client.add_property_to_site( @test_correct_site ) }.to raise_error ArgumentError
        end
        it "should not set an identical property if it exists" do
            @client.add_property_to_site( @test_correct_site,
                                                        {:propname => "contact-name",
                                                        :propvalue => "David Poindexter"} ).should be_false
        end
        it "should set the requested property on the site" do
            expect {@client.add_property_to_site( @test_correct_site,
                                                                    {:propname => "site.type.pdp",
                                                                    :propvalue => "true"} )}.to_not raise_error
        end
        it "should now have the correct property" do
            @client.add_property_to_site( @test_correct_site,
                                                        {:propname => "site.type.pdp",
                                                        :propvalue => "true"} )
            @client.get_site_property( @test_correct_site, "site.type.pdp").should_not be_false
        end
    end

    describe "#find_tool_in_site" do
        it "should require a site id" do
            expect{ @client.find_tool_in_site }.to raise_error ArgumentError
        end
        it "should require a tool id" do
            expect{ @client.find_tool_in_site( @test_correct_site ) }.to raise_error ArgumentError
        end
        it "should return false when the tool is not found" do
            @client.find_tool_in_site( @test_correct_site, "fake.tool.id").should be_false
        end
        it "should return true when the tool is found" do
            @client.find_tool_in_site( @test_correct_site, "sakai.iframe.site").should be_true
        end
    end

    describe "#find_page_in_site" do
        before(:all) do
            @test_site_id = "03eff8a7-cbae-4daa-9387-c06c05cf5e13"
            @test_page_title = "Home"
            @test_missing_page_title = "Bobby Brown"
        end
        it "should require a site_id" do
            expect{ @client.find_page_in_site }.to raise_error ArgumentError
        end
        it "should require a page_id" do
            expect{ @client.find_page_in_site( @test_site_id ) }.to raise_error ArgumentError
        end
        it "should return false if the page is not found" do
            @client.find_page_in_site( @test_site_id, @test_missing_page_title ).should be_false
        end
        it "should return true if the page already exists" do
            @client.find_page_in_site( @test_site_id, @test_page_title ).should be_true
        end
    end

    describe "#add_page_to_site" do
        before(:all) do
            @test_site_id = "03eff8a7-cbae-4daa-9387-c06c05cf5e13"
            @test_page_title = "Media Gallery"
            @test_dupe_page_title = "Home"
        end
        it "should require a site_id" do
            expect{ @client.add_page_to_site }.to raise_error ArgumentError
        end
        it "should require a page_title" do
            expect{ @client.add_page_to_site( @test_site_id ) }.to raise_error ArgumentError
        end
        it "should still return trueif the page already exists" do
            @client.add_page_to_site( @test_site_id, @test_dupe_page_title ).should be_true
        end
        it "should add a new page to the site" do
            random_new_page = "#{@test_page_title} - #{rand(1000).to_s}"
            @client.add_page_to_site( @test_site_id, random_new_page )
            @client.find_page_in_site( @test_site_id, random_new_page ).should be_true
        end
    end

    describe "#add_tool_to_site" do
        before(:all) do
            @test_site_id = "03eff8a7-cbae-4daa-9387-c06c05cf5e13"
            @test_page_title = "Media Gallery"
            @test_tool_title = "Media Gallery"
            @test_tool_id = "sakai.kaltura"
            @test_layout_hints = "0,0"
        end
        it "should require a site id" do
            expect{ @client.add_tool_to_site }.to raise_error ArgumentError
        end
        it "should require a page title" do
            expect{ @client.add_tool_to_site( @test_site_id ) }.to raise_error ArgumentError
        end
        it "should require a tool title" do
            expect{ @client.add_tool_to_site( @test_site_id,
                                                                @test_page_title )
                        }.to raise_error ArgumentError
        end
        it "should require a tool id" do
            expect{ @client.add_tool_to_site( @test_site_id,
                                                                @test_page_title,
                                                                @tool_title )
                        }.to raise_error ArgumentError
        end
        it "should not add a tool that is already in the site" do
            expect{ @client.add_tool_to_site( @test_site_id,
                                                                @test_page_title,
                                                                @tool_title,
                                                                "sakai.siteinfo" )
                        }.to_not raise_error
        end
        it "should add a tool to the site"  do
            @client.add_tool_to_site( @test_site_id,
                                                                @test_page_title,
                                                                @test_tool_title,
                                                                 @test_tool_id,
                                                                 "0,0")

            @client.find_tool_in_site( @test_site_id, @test_tool_id ).should be_true
        end
    end

    after(:all) do
        @client.logout(@client.session)
    end

end
