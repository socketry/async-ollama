# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/ollama/toolbox"

describe Async::Ollama::Toolbox do
	let(:toolbox) {subject.new}
	
	it "can register and call a tool" do
		toolbox.register("echo", {name: "echo"}) {|arguments| arguments}
		
		message = {
			function: {
				name: "echo",
				arguments: {foo: "bar"}
			}
		}
		
		result = toolbox.call(message)
		expect(result[:role]).to be == "tool"
		expect(result[:tool_name]).to be == "echo"
		expect(result[:content]).to be(:include?, "{\"foo\":\"bar\"}")
	end
	
	it "raises an error for unknown tool" do
		message = {
			function: {
				name: "unknown",
				arguments: {}
			}
		}
		result = toolbox.call(message)
		
		expect(result[:role]).to be == "tool"
		expect(result[:error]).to be(:include?, "Unknown tool: unknown")
	end
	
	it "returns explanations for all registered tools" do
		toolbox.register("echo", {name: "echo"}) {|arguments| arguments}
		toolbox.register("sum", {name: "sum"}) {|arguments| arguments["a"] + arguments["b"]}
		
		explanations = toolbox.explain
		expect(explanations).to be_a(Array)
		expect(explanations.size).to be == 2
	end
end
