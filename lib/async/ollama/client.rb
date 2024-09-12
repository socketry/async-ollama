# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/resource"
require_relative "generate"

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
				options[:model] ||= "llama3"
				
				Generate.post(self.with(path: "/api/generate"), options, &block)
			end
		end
	end
end
