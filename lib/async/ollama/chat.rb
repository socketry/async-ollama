# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/rest/representation"
require_relative "wrapper"

module Async
	module Ollama
		# Represents a chat response from the Ollama API, including message content, model, and timing information.
		class Chat < Async::REST::Representation[ChatWrapper]
			# @returns [Hash | nil] The message content, or nil if not present.
			def message
				self.value[:message]
			end
			
			# @returns [String | nil] The error message, or nil if not present.
			def error
				self.value[:error]
			end
			
			# @returns [Array(Hash) | nil] The tool calls, or nil if not present.
			def tool_calls
				if message = self.message
					message[:tool_calls]
				end
			end
			
			# @returns [String] The model name used to generate this response.
			def model
				self.value[:model]
			end
			
			# @return [Integer | nil] The time spent generating the response, in nanoseconds.
			def total_duration
				self.value[:total_duration]
			end
			
			# @return [Integer | nil] The time spent loading the model, in nanoseconds.
			def load_duration
				self.value[:load_duration]
			end
			
			# @return [Integer | nil] The number of tokens in the prompt (the token count).
			def prompt_eval_count
				self.value[:prompt_eval_count]
			end
			
			# @return [Integer | nil] The time spent evaluating the prompt, in nanoseconds.
			def prompt_eval_duration
				self.value[:prompt_eval_duration]
			end
			
			# @return [Integer | nil] The number of tokens in the response.
			def eval_count
				self.value[:eval_count]
			end
			
			# @return [Integer | nil] The time spent generating the response, in nanoseconds.
			def eval_duration
				self.value[:eval_duration]
			end
			
			# @return [Integer] The sum of prompt and response token counts.
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
