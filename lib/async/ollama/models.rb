# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		class Models < Async::REST::Representation[Wrapper]
			def names
				self.value[:models].map{|model| model[:name]}
			end
		end
	end
end
