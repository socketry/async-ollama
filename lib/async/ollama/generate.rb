# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		class Generate < Async::REST::Representation[Wrapper]
			# The response to the prompt.
			def response
				self.value[:response]
			end
			
			# The model used to generate the response.
			def model
				self.value[:model]
			end
		end
	end
end
