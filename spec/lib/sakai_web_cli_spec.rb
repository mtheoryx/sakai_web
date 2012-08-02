require 'spec_helper'
require 'yaml'
require 'pry'
describe SakaiWeb::CLI do
    describe "#start" do
        before(:all) do
            @ARGV = Array.new
        end
        it "should expect arguments" do
            expect{ SakaiWeb::CLI.start }.to raise_error
        end
        it "should expect an array of arguments" do
            expect{ SakaiWeb::CLI.start("@ARGV") }.to raise_error
        end
        it "should not be an empty array" do
            expect{ SakaiWeb::CLI.start(@ARGV) }.to raise_error
        end
        it "should fail with no action specified" do
            argv = @ARGV
            argv << "test"
            expect{ SakaiWeb::CLI.start(argv) }.to raise_error
        end
        it "should fail with no option file specified" do
            argv = @ARGV
            argv << "--action=add_property_to_site"
            expect{ SakaiWeb::CLI.start(argv) }.to raise_error
        end
        it "should fail with no target file specified" do
            argv = @ARGV
            argv << "--action=add_property_to_site"
            argv << "--object=/Users/davpoind2/Desktop/sakai_task_files/properties.yml"
            expect{ SakaiWeb::CLI.start(argv) }.to raise_error
        end

        describe "valid files", :focus => true do
            it "should raise an error if it's not a real file" do
                local_argv = Array.new
                local_argv << "--config=nothing"
                local_argv << "--action=add_property_to_site"
                local_argv << "--object=nothing"
                local_argv << "--target=anything"
                expect{ SakaiWeb::CLI.start(local_argv) }.to raise_error
            end
            it "should not raise an error if its a real file" do
                local_argv = Array.new
                local_argv << "--config=/Users/davpoind2/.sakai_web_config.yml"
                local_argv << "--action=add_property_to_site"
                local_argv << "--object=/Users/davpoind2/Desktop/sakai_task_files/properties.yml"
                local_argv << "--target=/Users/davpoind2/Desktop/sakai_task_files/test_sites.yml"
                expect{ SakaiWeb::CLI.start(local_argv) }.to_not raise_error
            end
        end
    end

    describe "#process" do

    end
end
