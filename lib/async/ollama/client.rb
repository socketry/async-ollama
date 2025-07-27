# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/rest/resource"

require_relative "generate"
require_relative "chat"
require_relative "models"
require_relative "pull"

module Async
	module Ollama
		MODEL = ENV.fetch("ASYNC_OLLAMA_MODEL", "llama3.1:latest")
		
		# Represents a connection to the Ollama service, providing methods to generate completions, chat, and list models.
		class Client < Async::REST::Resource
			# The default endpoint to connect to.
			ENDPOINT = Async::HTTP::Endpoint.parse("http://localhost:11434")
			
			# Generates a response from the given prompt using Ollama.
			# @parameter prompt [String] The prompt to generate a response from.
			# @parameter options [Hash] Additional options for the request.
			# @returns [Generate] The generated response representation.
			def generate(prompt, **options, &block)
				options[:prompt] = prompt
				options[:model] ||= MODEL
				
				Generate.post(self.with(path: "/api/generate"), options) do |resource, response|
					if block_given?
						yield response
					end
					
					Generate.new(resource, value: response.read, metadata: response.headers)
				end
			end
			
			# Sends a chat request with the given messages to Ollama.
			# @parameter messages [Array(Hash)] The chat messages to send.
			# @parameter options [Hash] Additional options for the request.
			# @returns [Chat] The chat response representation.
			def chat(messages, **options, &block)
				options[:model] ||= MODEL
				options[:messages] = messages
				
				Chat.post(self.with(path: "/api/chat"), options) do |resource, response|
					if block_given?
						yield response
					end
					
					Chat.new(resource, value: response.read, metadata: response.headers)
				end
			end
			
			# Retrieves the list of available models from Ollama.
			# @returns [Models] The models response representation.
			def models
				Models.get(self.with(path: "/api/tags"))
			end
			
			def pull(model)
				Pull.post(self.with(path: "/api/pull"), model: model) do |resource, response|
					if block_given?
						yield response
					end
					
					Pull.new(resource, value: response.read, metadata: response.headers)
				end
			end
		end
	end
end
