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
	
	let(:conversation) {Async::Ollama::Conversation.new(@client, temperature: 0.0)}
	
	it "can handle error responses" do
		expect do
			conversation.call({"role" => 10, "content" => ["This is not a valid message"]})
		end.to raise_exception(Async::Ollama::Conversation::ChatError)
	end
	
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
			numbers = arguments[:numbers]
			
			if numbers.is_a?(String)
				arguments[:numbers] = JSON.parse(numbers)
			end
			
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
			{role: "user", content: "I have them in that order: coffee, donut, sandwich."},
			{role: "assistant", content: "Got it! You have coffee, donut, and sandwich in that order."},
		]
		
		conversation = Async::Ollama::Conversation.new(client, messages: messages, temperature: 0.0)
		
		expect(conversation).to have_attributes(
			size: be == messages.size,
			token_count: be == 0,
		)
		
		conversation.summarize!
		
		response = conversation.call("What do I have, in the order I mentioned them?")
		message = response.message
		
		expect(message).to have_keys(
			role: be == "assistant",
			content: be =~ /coffee.*donut.*sandwich/mi
		)
		
		expect(conversation).to have_attributes(
			size: be == 4,
			token_count: be > 0,
		)
	end
end
