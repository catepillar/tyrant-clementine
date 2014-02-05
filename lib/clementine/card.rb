module Clementine
	class Card
		include Cinch::Plugin

		match /update \b(\S+)\b/i, :method => :update
		match /card (.*)/i, :method => :cards
		match /hash (.*)/i, :method => :deck_hash

		def self.keys
			return [:card, :hash]
		end

		def initialize(*args)
			super

			@cards = shared[:cards]
			@channels = shared[:channels]
		end

		def cards(m, card, *args)
			return unless @channels[m.channel][:card]
			card.downcase!
			m.reply @cards[card]
		end

		def unhash(hash)
			ret = true
			string = ""
			array = cards.scan(/-?../)
			array.each do | i |
				id = 0
				if(i[0] == '-')
					id = 4000
					id += BASE64.index(i[1])*64 + BASE64.index(i[2])
					ret = false if @cards.ids[id].nil?
					string += ", " if string != ""
					string += "#{@cards.ids[id]}"
				else
					id += BASE64.index(i[0])*64 + BASE64.index(i[1])
					if(id < 4000)
						ret = false if @cards.ids[id].nil?
						string += ", " if string != ""
						string += "#{@cards.ids[id]}"
					else
						string += " ##{id-4000}"
					end
				end
			end
			if ret
				return "#{m.user}: #{string}"
			else
				return nil
			end
		end

		def hash(cards)
			str = Array.new
			cards.downcase!
			array = cards.split(",")
			bot.log("#{array}")
			array.each do |a|
				a.strip!
				bot.log("#{a}")
				num = 0
				match = a.match(/\[(\d+)\](?:\s*#(\d+))?/)
				if match.nil?
					match = a.match(/\s*#(\d+)$/)
					unless match.nil?
						num = match[1].to_i+4000
						a.sub!(match[0],"")
					end
					id = @cards.find_id(a)
					val = id.first.to_i
					if val == -1
						str.push "(#{a}->#{id.last})"
						val = id[1].to_i
					end
					bot.log("#{id}")
					if(val > 4000)
						hash += "-" if(val > 4000)
						val -= 4000
					end
					hash += BASE64[val/64] + BASE64[val%64]
					hash += BASE64[num/64] + BASE64[num%64] if(num > 0)
				else
					val = match[1].to_i
					num = match[2].nil? ? 0 : match[2].to_i+4000
					if(val > 4000)
						hash += "-" if(val > 4000)
						val -= 4000
					end
					hash += BASE64[val/64] + BASE64[val%64]
					hash += BASE64[num/64] + BASE64[num%64] if(num > 0)
				end
			end
			return [str,hash]
		end

		def deck_hash(m, cards, *args)
			return unless @channels[m.channel][:hash]

			hash = unhash(cards) if(cards.match(/[^ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-\/]/).nil?)
			unless hash.nil?
				m.reply hash
				return
			end

			str,hash = hash(cards)

			m.reply "Corrections: #{str.join(", ")}" if str.length > 0
			m.reply "#{m.user.nick}: #{hash}"
		end
	end
end