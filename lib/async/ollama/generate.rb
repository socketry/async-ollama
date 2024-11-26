# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		DEFAULT_MODEL = "llama3"
		
		class Generate < Async::REST::Representation[Wrapper]
			# The response to the prompt.
			def response
				self.value[:response]
			end
			
			# The conversation context. Used to maintain state between prompts.
			def context
				self.value[:context]
			end
			
			# The model used to generate the response.
			def model
				self.value[:model]
			end
			
			# Generate a new response from the given prompt.
			# @parameter prompt [String] The prompt to generate a response from.
			# @yields {|response| ...} Optional streaming response.
			def generate(prompt, &block)
				self.class.post(self.resource, prompt: prompt, context: self.context, model: self.model, &block)
			end
		end
	end
end
