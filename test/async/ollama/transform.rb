# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

require "async/ollama"
require "sus/fixtures/async/reactor_context"

describe Async::Ollama::Transform do
	include Sus::Fixtures::Async::ReactorContext
	
	let(:transform) {Async::Ollama::Transform.new}
	
	it "can add content to a file" do
		content = <<~RUBY
			# frozen_string_literal: true
			
			def hello
				puts "hello"
			end
		RUBY
		
		result = transform.call(content,
			instruction: "Add a goodbye method that puts 'goodbye'."
		)
		
		expect(result).to be =~ /def goodbye/
		expect(result).to be =~ /goodbye/
		
		# Original content preserved:
		expect(result).to be =~ /def hello/
	end
	
	it "can merge a template without overwriting existing content" do
		existing = <<~RUBY
			# frozen_string_literal: true
			
			def after_gem_release_version_increment(version)
				context["utopia:project:update"].call
			end
		RUBY
		
		template = <<~RUBY
			# frozen_string_literal: true
			
			def after_gem_release_version_increment(version)
				context["releases:update"].call(version)
				context["utopia:project:update"].call
			end
			
			def after_gem_release(tag:, **options)
				context["releases:github:release"].call(tag)
			end
		RUBY
		
		result = transform.call(existing,
			instruction: "Add any methods from the template that are not already present. Do not modify existing methods.",
			template: template
		)
		
		# New method added from template:
		expect(result).to be =~ /def after_gem_release\b/
		# Existing method preserved - the original body line still present:
		expect(result).to be =~ /context\["utopia:project:update"\]\.call/
	end
	
	it "strips markdown code fences if the model adds them" do
		transform = Async::Ollama::Transform.new
		
		# Directly test the fence-stripping via a trivial transform:
		result = transform.call("hello = 1\n",
			instruction: "Change the value to 2."
		)
		
		expect(result).not.to be =~ /\A```/
		expect(result).not.to be =~ /```\z/
	end
end
