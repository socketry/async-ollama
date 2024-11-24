def initialize(...)
	super
	
	require 'async/ollama/client'
end

def models
	Async::Ollama::Client.open do |client|
		client.models.names
	end
end
