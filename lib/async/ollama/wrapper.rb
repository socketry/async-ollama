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
		class StreamingParser < ::Protocol::HTTP::Body::Wrapper
			def initialize(...)
				super
				
				@buffer = String.new.b
				@offset = 0
				
				@value = {}
			end
			
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
			
			def join
				self.each{}
				
				return @value
			end
		end
		
		class StreamingResponseParser < StreamingParser
			def initialize(...)
				super
				
				@response = String.new
				@value[:response] = @response
			end
			
			def each
				super do |line|
					response = line.delete(:response)
					@response << response
					@value.merge!(line)
					
					yield response
				end
			end
		end
		
		class StreamingMessageParser < StreamingParser
			def initialize(...)
				super
				
				@content = String.new
				@message = {content: @content, role: "assistant"}
				@value[:message] = @message
			end
			
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
		
		class Wrapper < Async::REST::Wrapper::Generic
			APPLICATION_JSON = "application/json"
			APPLICATION_JSON_STREAM = "application/x-ndjson"
			
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
		
		class ChatWrapper < Wrapper
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
