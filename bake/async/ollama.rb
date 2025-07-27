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

# Pulls the specified models from the Ollama API. If no models are specified, but there is a default model, it will pull that one.
# @parameter models [Array(String)] The names of the models to pull.
def pull(models: [Async::Ollama::MODEL])
	Async::Ollama::Client.open do |client|
		models.each do |model|
			client.pull(model) do |response|
				response.each do |line|
					puts line
				end
			end
		end
	end
end
