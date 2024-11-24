# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require "async/rest/wrapper/generic"
require "async/rest/wrapper/json"

require "protocol/http/body/wrapper"
require "protocol/http/body/buffered"

require "json"

module Async
	module Ollama
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
			
			class StreamingResponseParser < ::Protocol::HTTP::Body::Wrapper
				def initialize(...)
					super
					
					@buffer = String.new.b
					@offset = 0
					
					@response = String.new
					@value = {response: @response}
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
				
				def each
					super do |line|
						token = line.delete(:response)
						@response << token
						@value.merge!(line)
						
						yield token
					end
				end
				
				def join
					self.each{}
					
					return @value
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
	end
end
