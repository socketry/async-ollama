# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

module Async
	module Ollama
		class Tool
			def initialize(name, schema, &block)
				@name = name
				@schema = schema
				@block = block
			end
			
			attr :name
			attr :schema
			
			def call(message)
				@block.call(message)
			end
			
			def explain
				{
					type: "function",
					function: @schema,
				}
			end
		end
		
		class Toolbox
			def initialize
				@tools = {}
			end
			
			attr :tools
			
			def register(name, schema, &block)
				@tools[name] = Tool.new(name, schema, &block)
			end
			
			def call(message)
				function = message[:function]
				name = function[:name]
				
				if tool = @tools[name]
					arguments = function[:arguments]
					result = tool.call(arguments)
					
					return {
						role: "tool",
						tool_name: name,
						content: result.to_json,
					}
				else
					raise ArgumentError.new("Unknown tool: #{name}")
				end
			rescue => error
				return {
					role: "tool",
					tool_name: name,
					error: error.inspect,
				}
			end
			
			def explain
				@tools.values.map(&:explain)
			end
		end
	end
end
