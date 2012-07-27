require 'sakai_web'
require 'yaml'
require 'trollop'
require 'pry'

%w{post get put delete}.each do |local|
    require "sakai_web/cli/#{local}"
end

module SakaiWeb
    module CLI
        def self.start(args)
            raise unless args.is_a? Array

            #Options parsing
            p = Trollop::Parser.new do
                version "sakai_web #{SakaiWeb::VERSION} (c) 2012 David Poindexter, Indiana University"

                banner <<-EOS
SakaiWeb is a Ruby Gem with an optional CLI interface that simplifies working with
the Sakai Soap-based Web Services.

Usage:
        sakai_web [options]

where [options] are:

EOS
                opt :config, "Path to a YAML app config file.", :default => "#{Dir.home}/.sakai_web_config.yml", :type => String
                opt :action, "[REQUIRED] Action to perform on targets with objects.", :type => String
                opt :object, "[REQUIRED] Path to a YAML file with list of objects", :type => String
                opt :target, "[REQUIRED] Path to a YAML file with list of targets.", :type => String
            end
            opts = Trollop::with_standard_exception_handling p do
                raise Trollop::HelpNeeded if ARGV.empty? # show help screen
                p.parse args
            end
            # binding.pry
            # Handle required values
            raise ArgumentError.new("Must supply action argument." ) if opts[:action].nil?
            raise ArgumentError.new("Must supply object file." ) if opts[:object].nil?
            raise ArgumentError.new("Must supply target file." ) if opts[:target].nil?

            # Verify that files passed are valid files
            unless File.exists?(opts[:object])
                raise ArgumentError.new("Object file does not exist.")
            end
            unless File.exists?(opts[:target])
                raise ArgumentError.new("Target file does not exist.")
            end
            unless File.exists?(opts[:config])
                raise ArgumentError.new("Config file does not exist.")
            end


            # Dispatch actions
            self.dispatch( opts )

        end
    protected
        def self.dispatch( opts )

            client = SakaiWeb::Client.new( {:config_file => opts[:config]} )

            case opts[:action]
            when "add_property_to_site"
                self.add_property_to_site( client, opts )
            when "add_tool_to_site"
                self.add_tool_to_site( client, opts )
            else
                puts "No matching action."
            end

        end

        def self.add_property_to_site( client, opts )
            config = YAML.load_file( client.config_file )

            # login
            client.login

            # loop through properties and sites
            property_file = YAML.load_file( opts[:object] )
            site_file = YAML.load_file( opts[:target] )

            puts "Adding properties..."
            # For each property
            property_file["properties"].each do |prop|
                prop_name = prop["property"]["name"]
                prop_value = prop["property"]["value"]

                puts "Adding property #{prop_name}, #{prop_value} to #{site_file["sites"].length} sites..."
                site_file["sites"].each do |s|
                    puts "#{s["site"]}..."
                    # do a request for every site in our site list
                    client.add_property_to_site( s["site"], {:propname => prop_name, :propvalue => prop_value} )

                    puts "Finished adding property #{prop_name}, #{prop_value} to site #{s["site"]}..."
                end
                puts "Done adding property #{prop_name}, #{prop_value} to #{site_file["sites"].length} sites."
            end
            puts "Done adding properties."


            # logout
            client.logout( client.session )
        end

        def self.add_tool_to_site( client, opts )
            abort("add_tool_to_site CLI not implemented yet!")
        end
    end
end
