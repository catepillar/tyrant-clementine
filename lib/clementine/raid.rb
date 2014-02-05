module Clementine
	class Raid
		include Cinch::Plugin

		match /raid (\S+)/i, :method => :raid_user
		match /raidid (\d+)/i, :method => :raid_id

		def initialize(*args)
			super

			shared[:channel_keys].push :raid

			@channels = shared[:channels]
			@player = shared[:player]
		end

		def raid_user(m, username)
			return unless @channels[m.channel][:raid]
			user_id = Kongregate.lookup_name(username)
			if user_id.nil?
				m.reply "Player not found."
			else
				raid(m, resp["user_id"])
			end
		end


	def raid_id(m, raid_id)			#kinda ugly, but I don't want to refactor
		return unless @channels[m.channel][:raid]
		json = @player.send_request("getRaidInfo", "user_raid_id=" + raid_id.to_s)
		@names[raid_id.to_s] = @player.send_request("getName","target_id="+raid_id.to_s)["name"] if @names[raid_id.to_s] == nil
		time_l = (json["end_time"].to_i - Time.now.to_i)
		time_l = time_l*-1 if time_l < 0
		if(json.has_key? "end_time")
			str = @names[raid_id.to_s] + "'s " + Format(:bold,Format(:underline,@tyrant.get_raid(json["raid_id"])))
			str += ": #{json["raid_members"].keys.length} Members, #{json["health"]} Health, "
			time_left = ""
			time_left.concat((time_l/86400).to_s + "d ") if ((json["end_time"].to_i - Time.now.to_i)/86400) != 0
			time_l = time_l%86400
			time_left.concat "#{time_l/3600}hr " if ((json["end_time"].to_i - Time.now.to_i)/3600) != 0
			time_l = time_l%3600
			time_left.concat((time_l/60).to_s + "m ") if ((json["end_time"].to_i -  Time.now.to_i)/60) != 0
			time_l = time_l%60
			time_left.concat(time_l.to_s + "s")
			str += time_left + " left | http://www.kongregate.com/games/synapticon/tyrant?kv_joinraid=#{raid_id}" if json["end_time"].to_i - Time.now.to_i > 0
			str += "ended #{time_left} ago" if json["end_time"].to_i - Time.now.to_i <= 0
			m.reply str
		else
			m.reply "Error in raid id"
		end
	end

	end
end