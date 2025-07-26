# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		# Represents a generated response from the Ollama API.
		class Generate < Async::REST::Representation[Wrapper]
			# @returns [String | nil] The generated response, or nil if not present.
			def response
				self.value[:response]
			end
			
			# @returns [String] The model name used to generate the response.
			def model
				self.value[:model]
			end
		end
	end
end
