# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		# Represents the available models returned by the Ollama API.
		class Models < Async::REST::Representation[Wrapper]
			# @returns [Array(String)] The list of model names.
			def names
				self.value[:models].map {|model| model[:name]}
			end
		end
	end
end
