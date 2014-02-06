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
				raid(m, user_id)
			end
		end

		def format_seconds(time)
			days,time = time.divmod(86400)
			hours,time = time.divmod(3600)
			minutes,time = time.divmod(60)
			seconds = time
			string = ""
			string << days + "d " if days > 0
			string << [seconds,minutes,hours].map { |e| e.to_s.rjust(2,'0') }.join ':'
			return string
		end


	def raid_id(m, raid_id)			#kinda ugly, but I don't want to refactor
		return unless @channels[m.channel][:raid]
		json = @player.send_request("getRaidInfo", "user_raid_id=" + raid_id.to_s)
		if json.has_key? "duplicate_client"
			m.reply "Please wait a few seconds before retrying."
			return
		end
		name = @player.send_request("getName","target_id="+raid_id.to_s)["name"] if @names[raid_id.to_s] == nil
		time_left = (json["end_time"].to_i - Time.now.to_i)
		time_left = time_l*-1 if time_l < 0
		if(json.has_key? "end_time")
			str = name + "'s " + Format(:bold,Format(:underline,@raids.[json["raid_id"].to_i]))
			str += ": #{json["raid_members"].keys.length} Members, #{json["health"]} Health, "
			if(json["end_time"].to_i - Time.now.to_i > 0)
				str += format_seconds(time_left) + " left | http://www.kongregate.com/games/synapticon/tyrant?kv_joinraid=#{raid_id}"
			else
				str += "ended #{format_seconds(time_left)} ago"
			end
			m.reply str
		else
			m.reply "Error in raid id"
		end
	end

	end
end