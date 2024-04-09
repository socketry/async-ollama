# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require 'async/ollama'

describe Async::Ollama do
	it "should have a version number" do
		expect(Async::Ollama::VERSION).to be =~ /\d+\.\d+\.\d+/
	end
end
