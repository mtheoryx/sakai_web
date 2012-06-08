# SakaiWeb

This gem is for more easily using Ruby scripts to interact
with [Sakai's Web Services](https://confluence.sakaiproject.org/display/WEBSVCS/Home).

## Installation

Add this line to your application's Gemfile:

    gem 'sakai_web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sakai_web

## Usage

	require 'sakai_web'
	
	# Interact with Sakai Web services in a REST-ish way
	
	#Get
	SakaiWeb.get(service, data, auth)
	
	#Put
	SakaiWeb.put(service, data, auth)
	
	#Post
	SakaiWeb.post(service, data, auth)
	
	#Delete
	SakaiWeb.delete(service, data, auth)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
