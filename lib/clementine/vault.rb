module Clementine
	class Vault
		include Cinch::Plugin

		match /vault/i, :method => :vault


		def initialize(*args)
			super

			shared[:channel_keys].push :vault

			@player = shared[:player]

			@cards = shared[:cards]
			@channels = shared[:channels]

			t = Thread.new do
				@vault = @player.send_request("getMarketInfo")

				while @vault.has_key? "duplicate_client"
					sleep 5
					@vault = @player.send_request("getMarketInfo")
				end
				@vault_timer_first = Timer(10801 - (@vault["time"] - @vault["cards_for_sale_starting"]),
										method: :vault_timer_first,
										start_automatically: true
										)
				@time_offset = Time.now.to_i - @vault["time"]
			end
			#t.join
		end

		def vault_timer_first(*args)
			@vault_timer = Timer(10800, method: :vault_timer, start_automatically: true)
			names = Array.new
			@vault["cards_for_sale"].each { |c| names.push @cards.ids[c.to_i] }
			@channels.each { |c,v| Channel(c).send "[VAULT] #{names.join(", ")}" if v[:vault] }
			@vault_timer_first.stop
		end

		def vault_timer(*args)
			names = Array.new
			@vault["cards_for_sale"].each { |c| names.push @cards.ids[c.to_i] }
			@channels.each { |c,v| Channel(c).send "[VAULT] #{names.join(", ")}" if v[:vault] }
		end

		def vault(m, *args)
			return unless @channels[m.channel][:vault]
			m.reply @vault.inspect
			names = Array.new
			@vault["cards_for_sale"].each { |c| names.push @cards.ids[c.to_i] }
			time = 10800 - (Time.now.to_i - @vault["cards_for_sale_starting"] - @time_offset)
			m.reply "[VAULT] #{names.join(", ")}. Next update in #{time/3600}:#{"%02d" % (time%3600/60)}."
		end
	end
end