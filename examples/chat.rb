#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative 'lib/async/ollama'

require 'console'

terminal = Console::Terminal.for($stdout)
terminal[:reply] = terminal.style(:blue)
terminal[:reset] = terminal.reset

Async::Ollama::Client.open do |client|
	generator = client
	
	while input = $stdin.gets
		generator = generator.generate(input) do |response|
			terminal.write terminal[:reply]
			
			response.body.each do |token|
				terminal.write token
			end
			
			terminal.puts terminal[:reset]
		end
	end
end
