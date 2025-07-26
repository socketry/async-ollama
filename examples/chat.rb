#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require_relative "../lib/async/ollama"

require "console"

terminal = Console::Terminal.for($stdout)
terminal[:reply] = terminal.style(:blue)
terminal[:reset] = terminal.reset

model = ARGV.shift || "llama3.1:latest"

Async::Ollama::Client.open do |client|
	conversation = Async::Ollama::Conversation.new(client, model: model)
	
	while input = $stdin.gets
		message = conversation.call(input) do |response|
			terminal.write terminal[:reply]
			
			response.body.each do |chunk|
				terminal.write chunk
			end
			
			terminal.puts terminal[:reset]
		end
		
		terminal.puts "Current token count: #{conversation.token_count}"
		
		if conversation.size > 10
			conversation.summarize!
			terminal.puts "Conversation summarized to #{conversation.size} messages."
			conversation.messages.each do |message|
				terminal.puts "#{message[:role]}: #{message[:content]}"
			end
		end
	end
end
