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
- {ruby Async::Ollama::Generate} represents a single conversation response (with context) from the Ollama server.

## Example

~~~ ruby
require 'async/ollama'

Async::Ollama::Client.open do |client|
	generator = client.generate("Can you please tell me the first 10 digits of PI?")
	puts generator.response
	# Of course! The first 10 digits of pi are:
	#
	# 3.141592653
end
~~~

### Using a Specific Model

You can specify a model to use for generating responses:

~~~ ruby
require 'async/ollama'

Async::Ollama::Client.open do |client|
	generator = client.generate("Can you please tell me the first 10 digits of PI?", model: "llama3")
	puts generator.response
	# The first 10 digits of Pi (π) are:
	#
	# 3.141592653
	#
	# Let me know if you'd like more!
end
~~~
