# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		class Chat < Async::REST::Representation[ChatWrapper]
			# The response message.
			def message
				self.value[:message]
			end
			
			def error
				self.value[:error]
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
			
			# @return [Integer] The time spent generating the response, in nanoseconds.
			def total_duration
				self.value[:total_duration]
			end
			
			# @return [Integer] The time spent loading the model, in nanoseconds.
			def load_duration
				self.value[:load_duration]
			end
			
			# @return [Integer] The number of tokens in the prompt (the token count).
			def prompt_eval_count
				self.value[:prompt_eval_count]
			end
			
			# @return [Integer] The time spent evaluating the prompt, in nanoseconds.
			def prompt_eval_duration
				self.value[:prompt_eval_duration]
			end
			
			# @return [Integer] The number of tokens in the response.
			def eval_count
				self.value[:eval_count]
			end
			
			# @return [Integer] The time spent generating the response, in nanoseconds.
			def eval_duration
				self.value[:eval_duration]
			end
			
			def token_count
				count = 0
				
				if prompt_eval_count = self.prompt_eval_count
					count += prompt_eval_count
				end
				
				if eval_count = self.eval_count
					count += eval_count
				end
				
				return count
			end
		end
	end
end
