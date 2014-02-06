module Clementine
	class RaidLib
		def initialize(path = "cards.xml")

			@id = Hash.new


			if(not File.exists?(path))
				http = Net::HTTP.new('dev.tyrantonline.com', 80)
				resp = http.get("/assets/raids.xml")
				f = File.open(path, "w")
				f.puts resp.body
				f.close
			end

			@raid_xml = Nokogiri::XML(File.open(@path))
			@raids_xml.xpath("/root/raid").each do |xml|
				@id[xml.at("id").text.to_i] = xml.at("name").text
			end
		end

		def [](arg)
			if(@id.has_key? arg)
				return @id[arg]
			else
				return nil
			end
		end
	end
end