module Clementine
	class TyrantChannel
		def initialize(channel)

			@channel = channel
			@features = {}

		end
		attr_accessor :features

		def op?(user)
			User(user).refresh
			modes = @channel.users[user]

			(modes.include?("q") or modes.include?("a") or modes.include?("o"))
		end

		def to_s()
			@features.inspect.gsub(/"/,"")
		end

		def [](arg)
			return false unless @features.has_key? arg
			return @features[arg]
		end
	end
end