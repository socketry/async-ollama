# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

module Async
	module Ollama
		# Represents a tool that can be registered and called by the Toolbox.
		class Tool
			# Initializes a new tool with the given name, schema, and block.
			# @parameter name [String] The name of the tool.
			# @parameter schema [Hash] The schema describing the tool's function.
			# @parameter block [Proc] The implementation of the tool.
			def initialize(name, schema, &block)
				@name = name
				@schema = schema
				@block = block
			end
			
			# @attribute [String] The name of the tool.
			attr :name
			
			# @attribute [Hash] The schema for the tool.
			attr :schema
			
			# Calls the tool with the given message.
			# @parameter message [Hash] The message to process.
			# @returns [Object] The result of the tool's block.
			def call(message)
				@block.call(message)
			end
			
			# @returns [Hash] The explanation of the tool's function for API usage.
			def explain
				{
					type: "function",
					function: @schema,
				}
			end
		end
		
		# Manages a collection of tools and dispatches calls to them.
		class Toolbox
			# Initializes a new, empty toolbox.
			def initialize
				@tools = {}
			end
			
			# @attribute [Hash] The registered tools by name.
			attr :tools
			
			# Registers a new tool with the given name, schema, and block.
			# @parameter name [String] The name of the tool.
			# @parameter schema [Hash] The schema describing the tool's function.
			# @parameter block [Proc] The implementation of the tool.
			def register(name, schema, &block)
				@tools[name] = Tool.new(name, schema, &block)
			end
			
			# Calls a registered tool with the given message.
			# @parameter message [Hash] The message containing the function call.
			# @returns [Hash] The tool's response message.
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
			
			# @returns [Array(Hash)] The explanations for all registered tools.
			def explain
				@tools.values.map(&:explain)
			end
		end
	end
end
