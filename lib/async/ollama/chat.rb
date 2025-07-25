# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		class Chat < Async::REST::Representation[ChatWrapper]
			# The response message.
			def message
				self.value[:message]
			end
			
			def tool_calls
				if message = self.message
					message[:tool_calls]
				end
			end
			
			# The model used to generate the response.
			def model
				self.value[:model]
			end
		end
	end
end
