module Clementine
	class PlayerInfo
		include Cinch::Plugin

		match /faction (.*)/i, :method => :faction
		match /factionid (\d+)/i, :method => :faction_id
		match /link (.*)/i, :method => :link

		match /raid (\d+)/i, :method => :raid
		match /raid user (\S+)/i, :method => :raid_user

		match /player (\S+)\Z/i, :method => :player

		

		match /enable (.*)/i, :method => :enable
		match /disable (.*)/i, :method => :disable

		def initialize(*args)
			super
			@db = shared[:db]

			@config = shared[:config]["plugins"]["PlayerInfo"]

			@player = shared[:player]

			@names = Hash.new
			@tyrant = Tyrant.new
			@admins = @config["admins"]

			@cards = CardHash.new
			@dl = DamerauLevenshtein

			@channels = Hash.new

			m = Nokogiri::XML(File.open("missions.xml"))
			@total_factions = m.xpath("/root/faction").size
			a = Nokogiri::XML(File.open("achievements.xml"))
			@total_achievements = a.xpath("/root/achievement").size
		end
	end
end