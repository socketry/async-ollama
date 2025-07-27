# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		# Represents the response from pulling models from the Ollama API.
		class Pull < Async::REST::Representation[Wrapper]
		end
	end
end
