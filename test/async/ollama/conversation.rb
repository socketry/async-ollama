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
		
		conversation.toolbox.register("sum", name: "sum", description: "Get the sum of an array of numbers", parameters: {type: "object", properties: {numbers: {type: "array", items: {type: "number"}}}, required: ["numbers"]}) do |arguments|
			invoked = arguments
			
			arguments[:numbers].sum
		end
		
		response = conversation.call("You are a mathematician., Can you add the first 5 prime numbers?")
		
		expect(invoked).to be == {numbers: [2, 3, 5, 7, 11]}
		expect(response.message[:content]).to be =~ /28/
	end
end
