require 'spec_helper'
require 'yaml'

describe SakaiWeb::CLI, :focus => true do
    describe "#start" do
        it "should expect arguments" do
            expect{ SakaiWeb::CLI.start }.to raise_error (ArgumentError)
        end
    end

end
