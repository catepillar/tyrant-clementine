require 'cinch'
require 'digest/md5'
require 'net/http'
require 'uri'
require 'zlib'
require 'json'
require 'yaml'
require 'thread'
require 'mysql2'
require 'nokogiri'
require 'damerau-levenshtein'

require_relative 'clementine/channel.rb'
require_relative 'clementine/player.rb'
require_relative 'clementine/player_info.rb'
require_relative 'clementine/vault.rb'
require_relative 'clementine/card_lib.rb'

module Clementine
	BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
end
