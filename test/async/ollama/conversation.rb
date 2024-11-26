# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

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
	
	def timeout
		60*5
	end
	
	let(:conversation) {Async::Ollama::Conversation.new(@client)}
	
	it "can invoke a tool" do
		invoked = false
		conversation.toolbox.register("sum", '{"tool":"sum", "arguments":[...]}') do |message|
			invoked = message
			
			message[:arguments].sum
		end
		
		response = conversation.start("You are a mathematician.")
		inform response
		
		response = conversation.call("Can you add the first 5 prime numbers?")
		inform response
		
		expect(invoked).to be == {tool: "sum", arguments: [2, 3, 5, 7, 11]}
		expect(response).to be =~ /28/
	end
end
