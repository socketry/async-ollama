# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/ollama"
require "sus/fixtures/async/reactor_context"

describe Async::Ollama::Chat do
	include Sus::Fixtures::Async::ReactorContext
	
	attr :client
	
	before do
		@client = Async::Ollama::Client.open
	end
	
	after do
		@client.close
	end
	
	def chat(prompt, &block)
		@client.chat(prompt, options: {temperature: 0.0}, &block)
	end
	
	it "can generate a response" do
		messages = [
			{role: "user", content: "Please say Hello to me."},
		]
		
		chat = self.chat(messages)
		
		expect(chat.message).to have_keys(
			role: be == "assistant",
			content: be =~ /Hello/
		)
	end
	
	it "can stream a response" do
		chunks = []
		
		chat = self.chat([{role: "user", content: "Please say Hello to me."}]) do |response|
			response.each do |chunk|
				chunks << chunk
			end
		end
		
		expect(chunks).to be(:any?)
	end
	
	it "reports various details about the chat" do
		messages = [
			{role: "user", content: "What model are you?"},
		]
		
		chat = self.chat(messages)
		
		expect(chat).to have_attributes(
			model: be =~ /llama/,
			total_duration: be > 0,
			load_duration: be > 0,
			prompt_eval_count: be > 0,
			prompt_eval_duration: be > 0,
			eval_count: be > 0,
			eval_duration: be > 0,
			token_count: be > 0,
		)
	end
end
