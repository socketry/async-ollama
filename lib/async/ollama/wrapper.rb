# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "async/rest/wrapper/generic"
require "async/rest/wrapper/json"

require "protocol/http/body/wrapper"
require "protocol/http/body/buffered"

require "json"

module Async
	module Ollama
		# Parses streaming HTTP responses for Ollama, buffering and extracting JSON lines.
		class StreamingParser < ::Protocol::HTTP::Body::Wrapper
			# @parameter args [Array] Arguments for the parent initializer.
			def initialize(...)
				super
				
				@buffer = String.new.b
				@offset = 0
				
				@value = {}
			end
			
			# Reads the next JSON object from the stream.
			# @returns [Hash | nil] The next parsed object, or nil if the stream is empty.
			def read
				return if @buffer.nil?
				
				while true
					if index = @buffer.index("\n", @offset)
						line = @buffer.byteslice(@offset, index - @offset)
						@buffer = @buffer.byteslice(index + 1, @buffer.bytesize - index - 1)
						@offset = 0
						
						return ::JSON.parse(line, symbolize_names: true)
					end
					
					if chunk = super
						@buffer << chunk
					else
						return nil if @buffer.empty?
						
						line = @buffer
						@buffer = nil
						@offset = 0
						
						return ::JSON.parse(line, symbolize_names: true)
					end
				end
			end
			
			# Joins the stream, reading all objects and returning the final value.
			# @returns [Hash] The final parsed value.
			def join
				self.each{}
				
				return @value
			end
		end
		
		# Parses streaming responses for the Ollama API, collecting the response string.
		class StreamingResponseParser < StreamingParser
			# Initializes the parser with an empty response string.
			def initialize(...)
				super
				
				@response = String.new
				@value[:response] = @response
			end
			
			# Iterates over each response line, yielding the response string.
			# @returns [Enumerator] Yields each response string.
			def each
				super do |line|
					response = line.delete(:response)
					@response << response
					@value.merge!(line)
					
					yield response
				end
			end
		end
		
		# Parses streaming message responses for the Ollama API, collecting message content.
		class StreamingMessageParser < StreamingParser
			# Initializes the parser with an empty message content.
			def initialize(...)
				super
				
				@content = String.new
				@message = {content: @content, role: "assistant"}
				@value[:message] = @message
			end
			
			# Iterates over each message line, yielding the message content.
			# @returns [Enumerator] Yields each message content string.
			def each
				super do |line|
					message = line.delete(:message)
					content = message.delete(:content)
					@content << content
					@message.merge!(message)
					@value.merge!(line)
					
					yield content
				end
			end
		end
		
		# Wraps HTTP requests and responses for the Ollama API, handling content negotiation and parsing.
		class Wrapper < Async::REST::Wrapper::Generic
			APPLICATION_JSON = "application/json"
			APPLICATION_JSON_STREAM = "application/x-ndjson"
			
			# Prepares the HTTP request with appropriate headers and body.
			# @parameter request [Protocol::HTTP::Request] The HTTP request object.
			# @parameter payload [Protocol::HTTP::Response] The request payload.
			def prepare_request(request, payload)
				request.headers.add("accept", APPLICATION_JSON)
				request.headers.add("accept", APPLICATION_JSON_STREAM)
				
				if payload
					request.headers["content-type"] = APPLICATION_JSON
					
					request.body = ::Protocol::HTTP::Body::Buffered.new([
						::JSON.dump(payload)
					])
				end
			end
			
			# Selects the appropriate parser for the HTTP response.
			# @parameter response [Protocol::HTTP::Response] The HTTP response object.
			# @returns [Class] The parser class to use.
			def parser_for(response)
				content_type = response.headers["content-type"]
				media_type = content_type.split(";").first
				
				case media_type
				when APPLICATION_JSON
					return Async::REST::Wrapper::JSON::Parser
				when APPLICATION_JSON_STREAM
					return StreamingParser
				end
			end
		end
		
		# Wraps generate-specific HTTP responses for the Ollama API, selecting the appropriate parser.
		class GenerateWrapper < Wrapper
			# Selects the appropriate parser for the generate HTTP response.
			# @parameter response [Protocol::HTTP::Response] The HTTP response object.
			# @returns [Class] The parser class to use.
			def parser_for(response)
				content_type = response.headers["content-type"]
				media_type = content_type.split(";").first
				
				case media_type
				when APPLICATION_JSON
					return Async::REST::Wrapper::JSON::Parser
				when APPLICATION_JSON_STREAM
					return StreamingResponseParser
				end
			end
		end
		
		# Wraps chat-specific HTTP responses for the Ollama API, selecting the appropriate parser.
		class ChatWrapper < Wrapper
			# Selects the appropriate parser for the chat HTTP response.
			# @parameter response [Protocol::HTTP::Response] The HTTP response object.
			# @returns [Class] The parser class to use.
			def parser_for(response)
				content_type = response.headers["content-type"]
				media_type = content_type.split(";").first
				
				case media_type
				when APPLICATION_JSON
					return Async::REST::Wrapper::JSON::Parser
				when APPLICATION_JSON_STREAM
					return StreamingMessageParser
				end
			end
		end
	end
end
