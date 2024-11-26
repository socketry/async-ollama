# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative "generate"
require_relative "toolbox"

module Async
	module Ollama
		class Conversation
			def initialize(client, model: "llama3", context: nil)
				@client = client
				
				@toolbox = Toolbox.new
				
				@state = Generate.new(client.with(path: "/api/generate"), value: {
					model: model,
					context: context,
				})
			end
			
			attr :toolbox
			
			def context
				@state.context
			end
			
			def call(prompt)
				@state = @state.generate(prompt)
				
				while true
					response = @state.response
					if message = tool?(response)
						result = @toolbox.call(message)
						@state = @state.generate(result)
					else
						return response
					end
				end
			end
			
			def start(prompt)
				call(prompt + "\n\n" + @toolbox.explain)
			end
			
			private
			
			def tool?(response)
				if response.start_with?('{')
					begin
						return JSON.parse(response, symbolize_names: true)
					rescue => error
						Console.debug(self, error)
					end
				end
				
				return false
			end
		end
	end
end
