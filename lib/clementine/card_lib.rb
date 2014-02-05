#this is kinda hacked together for IRC use only.  Could probably stand to be cleaned up quite a bit.
module Clementine
	class CardLib

		attr_reader :names, :set, :id, :ids

		def initialize(path = "cards.xml")		#this creates a hash of names=>cards, and a hash of ids=>cards
			@dl = DamerauLevenshtein
			@path = path
			@names = Hash.new
			@id = Hash.new
			@keys = Array.new
			@ids = Array.new(4000)

			@types = {'9' => "Raider",
					'1' => "Imperial",
					'8' => "Righteous",
					'4' => "Xeno",
					'3' => "Bloodthirsty"
					}

			if(not File.exists?(path))
				http = Net::HTTP.new('dev.tyrantonline.com', 80)
				resp = http.get("/assets/cards.xml")
				f = File.open(path, "w")
				f.puts resp.body
				f.close
			end
			@cards_xml = Nokogiri::XML(File.open(@path))
			@set = Hash.new
			@cards_xml.xpath("/root/cardSet").each { |xpath| @set[xpath.at("id").text] = xpath.at("name").text }
			@cards_xml.xpath("/root/unit").each { |xpath| card(xpath) unless xpath.at("set").nil? }
			@keys = @names.keys
			return
		end

		def update
			http = Net::HTTP.new('dev.tyrantonline.com', 80)
			resp = http.get("/assets/cards.xml")
			f = File.open(@path, "w")
			f.puts resp.body
			f.close
			@cards_xml = Nokogiri::XML(File.open(@path))
			@set = Hash.new
			@cards_xml.xpath("/root/cardSet").each { |xpath| @set[xpath.at("id").text] = xpath.at("name").text }
			@cards_xml.xpath("/root/unit").each { |xpath| card(xpath) unless xpath.at("set").nil? }
		end

		def [](arg)
			if(@names[arg].nil?)
				min = 1000
				max = 0
				card = ""
				@keys.each do |key|
					x = @dl.distance(arg,key,5)
					if(x<min)
						min = x
						card = key
					end
					max = x if x > max
				end
				return "No exact match. Match confidence: #{(100.0-(min.to_f/max*100)).round(2)}%.\n" + @names[card]
			else
				return @names[arg]
			end
		end

		def find_id(name)
			if(@id[name].nil?)
				min = 1000
				max = 0
				card = "infantry"
				@keys.each do |key|
					x = @dl.distance(name,key,5)
					if(x<min)
						min = x
						card = key
					end
					max = x if x > max
				end
				l = card.gsub(",","")
				return -1, @id[l].first, @id[l].last
			else
				return @id[name]
			end
		end

		def card(xpath)

			name = xpath.at("name").text
			set = xpath.at("set").text.to_i
			name += "*" if set == 5002
			string = name

			set = xpath.at("set").text.to_i
			cid = xpath.at("id").text.to_i
			@ids[cid] = name.dup
			if(cidto_type(cid) == "Assault" or cidto_type(cid) == "Structure")
				string += " ["
				if(xpath.at("attack").nil?)
					string += "-/"
				else
					string += xpath.at("attack").text + "/"
				end
				string += "#{xpath.at("health").text}/#{xpath.at("cost").text}]"
			elsif cidto_type(cid) == "Commander"
				string += " #{xpath.at("health").text} HP"
			end
			string += " #{rareto_s xpath.at("rarity").text}" unless xpath.at("rarity").nil?
			string += " Unique" if @unique unless xpath.at("unique").nil?
			string += " #{@types[xpath.at("type").text]}" unless xpath.at("type").nil?
			string += " #{cidto_type cid}"
			string += ", " + @set[xpath.at("set").text]
			skills = Array.new
			if xpath.xpath(".//skill").length > 0
				string += "\n"
				xpath.xpath(".//skill").each {|skillpath| skills.push (skill skillpath) }
			end
			string += skills.join(", ")
			name = name.downcase!
			@names[name] = string
			@id[name.sub(",","")] = [cid,(xpath.at("name").text + "#{set == 5002 ? "*" : ""}")]
		end

		def cidto_type(cid)
			return "Assault" if cid/1000 % 4 == 0
			return "Commander" if cid/1000 % 4 == 1
			return "Structure" if cid/1000 % 4 == 2
			return "Action" if cid/1000 % 4 == 3
			return "Unknown Type"
		end

		def rareto_s(rarity)
			return "Common" if rarity == '1'
			return "Uncommon" if rarity == '2'
			return "Rare" if rarity == '3'
			return "Legendary" if rarity == '4'
		end


		def skill(xpath)
			name = xpath.attributes["id"].value
			name[0] = name[0].capitalize
			string = name
			string += " all" unless xpath.attributes["all"].nil?
			string += " #{@types[xpath.attributes["y"].value]}" unless xpath.attributes["y"].nil?
			if name == "Summon"
				string += " #{xpath.at("/root/unit[id=#{xpath.attributes["x"].value}]/name").text}"
			else
				string += " #{xpath.attributes["x"].value}" unless xpath.attributes["x"].nil?
			end
			string += " #{xpath.attributes["z"].value}" unless xpath.attributes["z"].nil?
			on = false
			if ! xpath.attributes["attacked"].nil?
				string += " on attacked"
				on = true
			end
			if ! xpath.attributes["play"].nil?
				if on
					string += ", play"
				else
					string += " on play"
					on = true
				end
			end
			if ! xpath.attributes["died"].nil?
				if on
					string += ", death"
				else
					string += " on death"
					on = true
				end
			end

			if ! xpath.attributes["kill"].nil?
				if on
					string += ", kill"
				else
					string += " on kill"
					on = true
				end
			end

			return string
		end

	end
end

