#!/usr/bin/env ruby

require_relative "lib/clementine.rb"

bot = Cinch::Bot.new do
	configure do |c|
		yaml = YAML.load_file("#{File.dirname(__FILE__)}/config.yaml")
		db = Mysql2::Client.new(:host=>yaml["mysql"]["yaml"],
								:username => yaml["mysql"]["username"],
								:password=>yaml["mysql"]["password"],
								:database=>yaml["mysql"]["database"],
								:reconnect => true
		                       )

		player = Player.new(:user_id => yaml["user_id"],
							:db => @db,
							:version=>yaml["version"],
							:user_agent=>yaml["user_agent"]
		                   )

		cards = CardLib.new("#{File.dirname(__FILE__)}/assets/cards.xml")

		c.nick     = yaml["bot"]["name"]
		c.server   = yaml["bot"]["server"]
		c.channels = yaml["channels"]
		c.plugins.plugins = yaml["plugins"].keys
		c.shared = {:db=>db,
		            :config=>yaml,
		            :player=>player,
		            :channels=>{}
		           }
		c.password = yaml["bot"]["password"] if yaml["bot"]["identify"]
	end
end

bot.start