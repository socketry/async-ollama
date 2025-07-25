# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

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
	
	it "can connect to the default endpoint" do
		chat = client.chat("Hello, this is a unit test. Please respond with the following text: Hello.")
		
		expect(chat.message).to have_keys(
			role: be == "assistant",
			content: be =~ /Hello/
		)
	end
end
