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
	
	def chat(prompt)
		@client.chat(prompt, options: {temperature: 0.0})
	end
	
	it "can connect to the default endpoint" do
		messages = [
			{role: "user", content: "Please say Hello to me."},
		]
		
		chat = self.chat(messages)
		
		expect(chat.message).to have_keys(
			role: be == "assistant",
			content: be =~ /Hello/
		)
	end
end
