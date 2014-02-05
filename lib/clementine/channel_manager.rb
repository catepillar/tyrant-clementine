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
				@channels[m.channel.name] = ClementineChannel.new(m.channel)
				shared[:plugins].each do |p|
					m.reply p.to_s
					if p.methods.include? :keys
						p.keys.each { |v| @channels[m.channel.name][v] = true }
					end
				end
			end
		end
	end
end