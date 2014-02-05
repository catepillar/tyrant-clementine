module Clementine
	class ChannelManager
		include Cinch::Plugin

		listen_to :join, :method => :join

		def initialize(channel)
			super

			@channels = shared[:channels]

		end

		def join(m, *args)
			if(m.user == @bot)
				@channels[m.channel.name] = Channel.new(m.channel)
				shared[:plugins].each do |p|
					p.keys.each { |v| @channels[m.channel.name][v] = true } if p.methods.include? keys
				end
			end
		end
	end
end