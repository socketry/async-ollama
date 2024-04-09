#!/usr/bin/env ruby
# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative '../lib/async/ollama'

require 'console'

class Entity
	def initialize(client, name, background)
		@name = name
		@background = background
		
		@generator = client
	end
	
	attr :name
	attr :background
	
	def broadcast(room, from, input)
		Async do
			if from
				prompt = "#{from.name} says: #{input}"
				@generator = @generator.generate(prompt)
			else
				@generator = @generator.generate(input)
			end
			
			sleep(rand(1..10))
			
			room.broadcast(self, @generator.response)
		end
	end
end

class Room
	SYSTEM = "You are role playing as a character. You will receive textual input from other players and must respond according to your background. Stay in character at all times."
	
	def initialize
		@entities = []
	end
	
	def add(entity)
		@entities << entity
		
		prompt = "#{SYSTEM}\nYour name is #{entity.name} and you are: #{entity.background}"
		
		entity.broadcast(self, nil, prompt)
	end
	
	def broadcast(entity, input)
		$stderr.puts "*** Entity #{entity.name} says *** #{input}"
		
		@entities.each do |target|
			unless entity.equal?(target)
				target.broadcast(self, entity, input)
			end
		end
	end
end

Async::Ollama::Client.open do |client|
	alice = Entity.new(client, "Alice", "A young elegant lady whom is obsessed with computers.")
	bob = Entity.new(client, "Bob", "A middle age man having an identity crisis.")
	cat = Entity.new(client, "Cat", "A cat that is hungry.")
	
	room = Room.new
	room.add(alice)
	room.add(bob)
	room.add(cat)
end
