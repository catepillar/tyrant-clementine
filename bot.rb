#!/usr/bin/env ruby

require_relative "lib/clementine.rb"

bot = Cinch::Bot.new do
	configure do |c|
		yaml = YAML.load_file("#{File.dirname(__FILE__)}/config.yaml")
		opts = {:host=>yaml["mysql"]["host"],
								:username => yaml["mysql"]["username"],
								:database=>yaml["mysql"]["database"],
								:reconnect => true}
		opts[:password] = yaml["mysql"]["password"] if yaml["mysql"].has_key? "password"
		db = Mysql2::Client.new(opts)

		player = Clementine::Player.new(:user_id => yaml["user_id"],
							:db => db,
							:version=>yaml["version"],
							:user_agent=>yaml["user_agent"]
		                   )

		cards = Clementine::CardLib.new("#{File.dirname(__FILE__)}/assets/cards.xml")
		raids = Clementine::RaidLib.new("#{File.dirname(__FILE__)}/assets/raids.xml")

		plugins = yaml["plugins"].keys.collect { |p| Object.const_get("Clementine::#{p}") }
		base_plugins = [Clementine::ChannelManager, RubyEval]

		c.nick     = yaml["bot"]["name"]
		c.server   = yaml["bot"]["server"]
		c.channels = yaml["channels"]
		c.plugins.plugins = plugins+base_plugins
		c.shared = {:db=>db,
		            :config=>yaml,
		            :player=>player,
		            :channels=>{},
		            :plugins=>plugins,
		            :cards => cards,
		            :raids => raids,
		            :channel_keys=>[],
		            :names => {}
		           }
		c.password = yaml["bot"]["password"] if yaml["bot"].has_key? "password"
	end
end

bot.start
