# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "async/ollama/wrapper"
require "protocol/http/body/buffered"

describe Async::Ollama::StreamingParser do
	it "parses multiple JSON objects from a buffered body" do
		json_lines = [
			{"foo" => 1}.to_json + "\n",
			{"bar" => 2}.to_json + "\n"
		].join
		body = ::Protocol::HTTP::Body::Buffered.new([json_lines])
		parser = subject.new(body)
		
		first = parser.read
		expect(first).to have_keys(foo: be == 1)
		second = parser.read
		expect(second).to have_keys(bar: be == 2)
		third = parser.read
		expect(third).to be_nil
	end
	
	it "parses a single JSON object without newline at end" do
		json_line = {"baz" => 3}.to_json
		body = ::Protocol::HTTP::Body::Buffered.new([json_line])
		parser = subject.new(body)
		
		result = parser.read
		expect(result).to have_keys(baz: be == 3)
		final = parser.read
		expect(final).to be_nil
	end
end
