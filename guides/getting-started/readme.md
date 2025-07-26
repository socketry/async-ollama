# Getting Started

This guide explains how to get started with the `async-ollama` gem.

## Installation

Add the gem to your project:

~~~ bash
$ bundle add async-ollama
~~~

### Ollama

You'll also need to install and start Ollama. You can find instructions for doing so at [https://ollama.com](https://ollama.com).

## Core Concepts

- The {ruby Async::Ollama::Client} is used for interacting with the Ollama server.
- {ruby Async::Ollama::Conversation} is used to manage a conversation with an agent.
- {ruby Async::Ollama::Generate} represents a single generation operation.

## Example

~~~ ruby
require 'async/ollama'

Async::Ollama::Client.open do |client|
	generator = client.generate("Can you please tell me the first 10 digits of PI?")
	puts generator.response
	# Of course! The first 10 digits of pi are:
	#
	# 3.141592653
	
	conversation = Async::Ollama::Conversation.new(client)
	reply = conversation.call("Hello")
	puts reply.response
	# It's nice to meet you. Is there something I can help you with or would you like to chat?
	reply = conversation.call("Could you tell me a joke?")
	puts reply.response
	# Why did the scarecrow win an award? Because he was outstanding in his field!
end
~~~

### Using a Specific Model

If you'd like to override the default model, you can use the `ASYNC_OLLAMA_MODEL` environment variable. If you set this variable, it will be used for all requests made by the client which do not specify a model explicitly.

Alternatively, you can specify the model directly, e.g.:

~~~ ruby
require 'async/ollama'

Async::Ollama::Client.open do |client|
	generator = client.generate("Hello", model: "gemma3")
	puts generator.response
	
	conversation = Async::Ollama::Conversation.new(client, model: "gemma3")
	reply = conversation.call("Hello")
end
~~~
