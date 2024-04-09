# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/rest/representation'
require_relative 'wrapper'

module Async
	module Ollama
		class Generate < Async::REST::Representation[Wrapper]
			def response
				self.value[:response]
			end
			
			def context
				self.value[:context]
			end
			
			def model
				self.value[:model]
			end
			
			def generate(prompt, &block)
				self.class.post(self.resource, prompt: prompt, context: self.context, model: self.model, &block)
			end
		end
	end
end
