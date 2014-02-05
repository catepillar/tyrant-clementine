module Clementine
	class ChannelManager
		include Cinch::Plugin

		listen_to :join, :method => :join

		def initialize(channel)
			super

			@channels = shared[:channels]
			@keys = shared[:channel_keys]

		end

		def join(m, *args)
			if(m.user == @bot)
				@channels[m.channel.name] = ClementineChannel.new(m.channel)
				@keys.each do |key|
					@channels[m.channel.name].features[key] = true
				end
			end
		end
	end
end