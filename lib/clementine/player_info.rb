module Clementine
	class PlayerInfo
		include Cinch::Plugin

		match /faction (.*)/i, :method => :faction
		match /factionid (\d+)/i, :method => :faction_id
		match /link (.*)/i, :method => :link

		match /raid (\d+)/i, :method => :raid
		match /raid user (\S+)/i, :method => :raid_user

		match /player (\S+)\Z/i, :method => :player

		match /update \b(\S+)\b/i, :method => :update
		match /card (.*)/i, :method => :cards
		match /hash (.*)/i, :method => :deck_hash

		match /vault/i, :method => :vault

		match /enable (.*)/i, :method => :enable
		match /disable (.*)/i, :method => :disable

		def initialize(*args)
			super
			@db = shared[:db]

			@config = shared[:config]["plugins"]["PlayerInfo"]

			@player = Player.new(:user_id => @config["user_id"],
			                     :db => @db,
			                     :version=>shared[:config]["version"],
			                     :user_agent=>shared[:config]["user_agent"])

			@names = Hash.new
			@tyrant = Tyrant.new
			@admins = @config["admins"]

			@cards = CardHash.new
			@dl = DamerauLevenshtein

			@channels = Hash.new

			@vault = @player.send_request("getMarketInfo")
			@vault_timer_first = Timer(10801 - (@vault["time"] - @vault["cards_for_sale_starting"]),
			                           method: :vault_timer_first,
			                           start_automatically: true
			                          )
			@time_offset = Time.now.to_i - @vault["time"]

			m = Nokogiri::XML(File.open("missions.xml"))
			@total_factions = m.xpath("/root/faction").size
			a = Nokogiri::XML(File.open("achievements.xml"))
			@total_achievements = a.xpath("/root/achievement").size
		end
	end
end