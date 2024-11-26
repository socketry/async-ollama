# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

module Async
	module Ollama
		class Tool
			def initialize(name, explain, &block)
				@name = name
				@explain = explain
				@block = block
			end
			
			attr :name
			attr :explain
			
			def call(message)
				@block.call(message)
			end
		end
		
		class Toolbox
			PROMPT = "You have access to the following tools, which you can invoke by replying with a single line of valid JSON:\n\n"
			
			USAGE = <<~EOF
				- Use these tools to enhance your ability to answer user queries accurately.
				
				- When you need to use a tool to answer the user's query, respond **only** with the JSON invocation.
					- Example: {"tool":"ruby", "code": "5+5"}
					- **Do not** include any explanations, greetings, or additional text when invoking a tool.
					- If you are dealing with numbers, ensure you provide them as Integers or Floats, not Strings.
				
				- After invoking a tool:
					1. You will receive the tool's result as the next input.
					2. Use the result to formulate a direct, user-friendly response that answers the original query.
					3. Assume the user is unaware of the tool invocation or its result, so clearly summarize the answer without referring to the tool usage or the response it generated.
				
				- Continue the conversation naturally after providing the answer. Ensure your responses are concise and user-focused.
				
				## Example Flow:
				
				- User: "Why doesn't 5 + 5 equal 11?"
				- Assistant (invokes tool): {"tool": "ruby", "code": "5+5"}
				- (Tool Result): 10
				- Assistant: "The result of 5 + 5 is 10, because addition follows standard arithmetic rules."
				
				Remember, invoke tools silently and use their results seamlessly in your responses to the user.
			EOF
			
			def initialize
				@tools = {}
			end
			
			attr :tools
			
			def register(name, explain, &block)
				@tools[name] = Tool.new(name, explain, &block)
			end
			
			def call(message)
				name = message[:tool]
				
				if tool = @tools[name]
					result = tool.call(message)
					
					return {result: result}.to_json
				else
					raise ArgumentError.new("Unknown tool: #{name}")
				end
			rescue => error
				{error: error.message}.to_json
			end
			
			def explain
				buffer = String.new
				buffer << PROMPT
				
				@tools.each do |name, tool|
					buffer << tool.explain
				end
				
				buffer << "\n" << USAGE << "\n"
				
				return buffer
			end
		end
	end
end
