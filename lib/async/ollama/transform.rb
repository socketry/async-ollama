# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require_relative "client"

module Async
	module Ollama
		# Transforms file content using a local Ollama model.
		#
		# Useful for intelligently merging template changes into existing files,
		# without overwriting user modifications.
		#
		# @example Transform a bake.rb to add missing release hooks:
		#   new_content = Async::Ollama::Transform.call(
		#     File.read("bake.rb"),
		#     instruction: "Add the after_gem_release hooks if they are not already present.",
		#     template: File.read(template_path)
		#   )
		#   File.write("bake.rb", new_content)
		class Transform
			SYSTEM_PROMPT = <<~PROMPT
				You are a precise file transformation tool.
				When given a file and instructions, you output ONLY the transformed file content.
				Do not add any explanation, preamble, summary of changes, or markdown code fences.
				Output the raw file content exactly as it should be written to disk.
				Preserve all existing content unless the instructions explicitly require removal.
				If a reference template is provided, use it as a structural guide for what to add or how to format new content — do not copy it verbatim or replace existing content with it.
			PROMPT
			
			# @parameter model [String] The Ollama model to use.
			def initialize(model: MODEL)
				@model = model
			end
			
			# Transform file content according to the given instruction.
			#
			# @parameter content [String] The current file content.
			# @parameter instruction [String] What change to make.
			# @parameter template [String | nil] An optional reference example showing the desired structure.
			# @returns [String] The transformed file content.
			def call(content, instruction:, template: nil)
				messages = [
					{role: "system", content: SYSTEM_PROMPT},
					{role: "user", content: build_prompt(content, instruction, template)}
				]
				
				Client.open do |client|
					reply = client.chat(messages, model: @model)
					
					reply.response
				end
			end
			
			# Convenience class method.
			#
			# @parameter content [String] The current file content.
			# @parameter options [Hash] Keyword arguments forwarded to {#call}.
			# @returns [String] The transformed file content.
			def self.call(content, **options)
				new.call(content, **options)
			end
			
			private
			
			def build_prompt(content, instruction, template = nil)
				parts = []
				parts << "## Current file\n\n```\n#{content}\n```"
				parts << "## Change requested\n\n#{instruction}"
				
				if template
					parts << "## Reference template\n\n```\n#{template}\n```"
				end
				
				parts.join("\n\n")
			end
		end
	end
end
