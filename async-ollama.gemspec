# frozen_string_literal: true

require_relative "lib/async/ollama/version"

Gem::Specification.new do |spec|
	spec.name = "async-ollama"
	spec.version = Async::Ollama::VERSION
	
	spec.summary = "A asynchronous interface to the ollama chat service"
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/async-ollama"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/falcon/",
		"source_code_uri" => "https://github.com/socketry/async-ollama.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "async"
	spec.add_dependency "async-rest", "~> 0.13.0"
end
