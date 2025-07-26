# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/ollama"
require "sus/fixtures/async/reactor_context"

describe Async::Ollama::Client do
	include Sus::Fixtures::Async::ReactorContext
	
	attr :client
	
	before do
		@client = Async::Ollama::Client.open
	end
	
	after do
		@client.close
	end
	
	def generate(prompt, &block)
		@client.generate(prompt, options: {temperature: 0.0}, &block)
	end
	
	it "can generate a response" do
		generate = self.generate("Please say Hello to me.")
		
		expect(generate.response).to be =~ /Hello/
	end
	
	it "can stream a response" do
		chunks = []
		
		generate = self.generate("Please say Hello to me.") do |response|
			response.each do |chunk|
				chunks << chunk
			end
		end
		
		expect(chunks).to be(:any?)
	end
	
	it "reports various details about the generation" do
		generate = self.generate("What model are you?")
		
		expect(generate).to have_attributes(
			model: be =~ /llama/,
			response: be_a(String)
		)
	end
end
