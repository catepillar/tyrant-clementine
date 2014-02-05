module Clementine
	class FactionInfo
		include Cinch::Plugin

		match /faction (.*)/i, :method => :faction
		match /factionid (\d+)/i, :method => :faction_id
		match /link (.*)/i, :method => :link

		def initialize(*args)
			super

			@channels = shared[:channels]
			@db = shared[:db]

			@dl = DamerauLevenshtein
		end

		def spell_check(name)
			name.downcase!
			names = Array.new
			@db.query("SELECT DISTINCT name FROM factions where level>0").each do |r|
				names.push r["name"]
			end

			min = [1000,1000,1000]
			faction = ["","",""]

			names.each do |n|
				x = @dl.distance(name, n.downcase,3,5)
				if(x >= 6)

				elsif x < min[0]
					min.insert(0,x)
					min.pop
					faction.insert(0,n)
					faction.pop
				elsif x < min[1]
					min.insert(1,x)
					min.pop
					faction.insert(1,n)
					faction.pop
				elsif x < min[2]
					min[2] = x
					faction[2] = n
				end
			end
			faction.delete("")
			if(faction.length == 0)
				return []
			end
			factions = Array.new
			if faction.length > 0
				@db.query("SELECT * FROM factions WHERE name LIKE \"#{@db.escape(faction[0])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
					factions.push r
				end
				if faction.length > 1
					@db.query("SELECT * FROM factions WHERE name LIKE \"#{@db.escape(faction[1])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
						factions.push r
					end
					if faction.length > 2
						@db.query("SELECT * FROM factions WHERE name LIKE \"#{@db.escape(faction[2])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
							factions.push r
						end
					end
				end
			end
		end

		def faction(m, name, *args)
			return unless @channels[m.channel][:faction]
			factions = Array.new

			@db.query("SELECT * FROM factions WHERE name LIKE \"#{@db.escape(name)}\" ORDER BY rating desc, level desc, wins desc LIMIT 3").each do |r|
				factions.push r
			end
			@bot.log(factions.inspect)
			if factions.length == 0
				m.reply "No exact match found. Searching for 3 most similar names"
				factions = spell_check(name)

			end


			factions.each do |faction|
				if (faction[3] > 0)
					m.reply("#{faction[1]}: Level #{faction[3]}, #{faction[4]} FP, #{faction[10]*faction[11]/100}/#{faction[10]} Active Members, #{faction[5]}W/#{faction[6]}L, #{faction[9]} Tiles")
					m.reply("     Message: #{faction[7]}") if faction[7].strip != ""
				else
					m.reply("#{faction[1]}: Disbanded, #{faction[4]} FP, #{faction[5]}W/#{faction[6]}L")
				end
			end
			m.reply "No records of such a faction." if factions.length == 0
		end

		def faction_id(m,id,*args)
			return unless @channels[m.channel][:faction]
			factions = Array.new
			@db.query("SELECT * FROM factions WHERE id=#{id.to_i}").each do |r|
				factions.push r
			end
			factions.each do |faction|
				if (faction[3] > 0)
					m.reply("#{faction[1]}: Level #{faction[3]}, #{faction[4]} FP, #{faction[10]*faction[11]/100}/#{faction[10]} Active Members, #{faction[5]}W/#{faction[6]}L, #{faction[9]} Tiles")
					m.reply("     Message: #{faction[7]}") if faction[7].strip != ""
				else
					m.reply("#{faction[1]}: Disbanded, #{faction[4]} FP, #{faction[5]}W/#{faction[6]}L")
				end
			end
			m.reply "No records of such a faction." if factions.length == 0
		end

		def link(m, name, *args)
			return unless @channels[m.channel][:faction]
			factions = Array.new
			@db.query("SELECT name,id FROM factions WHERE name LIKE \"#{@db.escape(name)}\" and level>0 ORDER BY rating desc limit 3").each do |r|
				factions.push r
			end
			if factions.length == 0
				m.reply "No exact match found. Searching for 3 most similar names"
				name.downcase!
				names = Array.new
				@db.query("SELECT DISTINCT name FROM factions where level>0").each do |r|
					names.push r[0]
				end
				min = [1000,1000,1000]
				faction = ["","",""]
				names.each do |n|
					x = @dl.distance(name, n.downcase,3,5)
					if(x >= 6)

					elsif x < min[0]
						min.insert(0,x)
						min.pop
						faction.insert(0,n)
						faction.pop
					elsif x < min[1]
						min.insert(1,x)
						min.pop
						faction.insert(1,n)
						faction.pop
					elsif x < min[2]
						min[2] = x
						faction[2] = n
					end
				end
				faction.delete("")
				if(faction.length == 0)
					m.reply("No close matches")
					return
				end
				factions = Array.new
				if faction.length > 0
					@db.query("SELECT name,id FROM factions WHERE name LIKE \"#{@db.escape(faction[0])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
						factions.push r
					end
					if faction.length > 1
						@db.query("SELECT name,id FROM factions WHERE name LIKE \"#{@db.escape(faction[1])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
							factions.push r
						end
						if faction.length > 2
							@db.query("SELECT name,id FROM factions WHERE name LIKE \"#{@db.escape(faction[2])}\" and level>0 ORDER BY rating desc limit 1").each do |r|
								factions.push r
							end
						end
					end
				end
				factions.each { |faction| m.reply(faction[0] + ": http://www.kongregate.com/games/synapticon/tyrant?kv_apply=#{faction[1]}") }
				return
			end
			factions.each { |faction| m.reply("http://www.kongregate.com/games/synapticon/tyrant?kv_apply=#{faction[1]}") }
			m.reply "No records of such a faction." if factions.length == 0
		end
	end
end