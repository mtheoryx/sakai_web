require 'sakai_web'
%w{post get put delete}.each do |local|
  require "sakai_web/cli/#{local}"
end
require "pry"
module SakaiWeb
    module CLI
        def self.start(args)
        end
    end
end
