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
	
	def timeout
		60*5
	end
	
	let(:conversation) {Async::Ollama::Conversation.new(@client)}
	
	it "can invoke a tool" do
		invoked = false
		
		conversation.toolbox.register("sum",
			name: "sum",
			description: "Get the sum of an array of numbers",
			examples: [
				{numbers: [1, 2, 3]},
				{numbers: [4, 5, 6]},
			],
			parameters: {
				type: "object",
				properties: {
					numbers: {
						type: "array",
						items: {
							type: "number"
						}
					}
				},
				required: ["numbers"]
			}
		) do |arguments|
			invoked = arguments
			
			arguments[:numbers].sum
		end
		
		response = conversation.call("You are a mathematician., Can you add the first 5 prime numbers? (You must use the sum tool)")
				
		expect(invoked).to be == {numbers: [2, 3, 5, 7, 11]}
		expect(response.message[:content]).to be =~ /28/
	end
	
	it "can summarize a conversation" do
		messages = [
			{role: "user", content: "Hello, I have a coffee."},
			{role: "assistant", content: "Great! Coffee is a wonderful beverage."},
			{role: "user", content: "I also have a donut."},
			{role: "assistant", content: "Donuts are a delicious treat to enjoy with coffee."},
			{role: "user", content: "I also have a sandwich."},
			{role: "assistant", content: "Sandwiches are a great meal."},
		]
		
		conversation = Async::Ollama::Conversation.new(client, messages: messages)
		
		conversation.summarize!

		response = conversation.call("What do I have, in the order I mentioned them?")
		message = response.message
		
		expect(message).to have_keys(
			role: be == "assistant",
			content: be =~ /coffee.*donut.*sandwich/mi
		)
	end
end
