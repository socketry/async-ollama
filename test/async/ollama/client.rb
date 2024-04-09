# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/ollama'
require 'sus/fixtures/async/reactor_context'

describe Async::Ollama::Client do
	include Sus::Fixtures::Async::ReactorContext
	
	attr :client
	
	def before
		super
		
		@client = Async::Ollama.connect
	end
	
	def after
		@client.close
		
		super
	end
	
	it "can connect to the default endpoint" do
		response = client.generate("Hello")
		
		response.body.each do |line|
			puts line
		end
	ensure
		generate.close
	end
end
