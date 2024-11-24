# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

def initialize(...)
	super
	
	require "async/ollama/client"
end

def models
	Async::Ollama::Client.open do |client|
		client.models.names
	end
end
