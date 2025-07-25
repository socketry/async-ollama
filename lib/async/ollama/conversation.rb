# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "generate"
require_relative "toolbox"

module Async
	module Ollama
		class Conversation
			MODEL = "llama3.1:latest"
			
			def initialize(client, model: MODEL, messages: [])
				@client = client
				@model = model
				@messages = messages
				
				@toolbox = Toolbox.new
			end
			
			attr :toolbox
			
			attr :messages
			
			def call(prompt)
				@messages << {
					role: "user",
					content: prompt
				}
				
				while true
					response = @client.chat(@messages, model: @model, tools: @toolbox.explain)
					@messages << response.message
					
					tool_calls = response.tool_calls
					
					return response if tool_calls.nil? || tool_calls.empty?
					
					tool_calls.each do |tool_call|
						@messages << @toolbox.call(tool_call)
					end
				end
			end
		end
	end
end
