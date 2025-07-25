# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/resource"

require_relative "generate"
require_relative "chat"
require_relative "models"

module Async
	module Ollama
		# Represents a connection to the Ollama service.
		class Client < Async::REST::Resource
			# The default endpoint to connect to.
			ENDPOINT = Async::HTTP::Endpoint.parse("http://localhost:11434")
			
			# Generate a response from the given prompt.
			# @parameter prompt [String] The prompt to generate a response from.
			def generate(prompt, **options, &block)
				options[:prompt] = prompt
				options[:model] ||= DEFAULT_MODEL
				
				Generate.post(self.with(path: "/api/generate"), options) do |resource, response|
					if block_given?
						yield response
					end
					
					Generate.new(resource, value: response.read, metadata: response.headers)
				end
			end
			
			def chat(prompt, **options, &block)
				options[:model] ||= "llama3"
				options[:messages] ||= []
				
				if prompt.is_a?(String)
					message = {
						role: "user",
						content: prompt
					}
				else
					message = prompt
				end
				
				options[:messages] << message
				
				Chat.post(self.with(path: "/api/chat"), options) do |resource, response|
					if block_given?
						yield response
					end
					
					Chat.new(resource, value: response.read, metadata: response.headers)
				end
			end
			
			def models
				Models.get(self.with(path: "/api/tags"))
			end
		end
	end
end
