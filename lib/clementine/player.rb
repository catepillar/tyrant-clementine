require 'digest/md5'
require "net/http"
require "uri"
require 'zlib'
require 'json'
require 'yaml'
require 'mysql2'

module Clementine
	class Player
		
		def initialize(opts = {})
			@user_id=opts[:user_id].to_i
			yaml = YAML.load_file("../../config.yaml")
			@db = Mysql2::Client.new(	:host=>yaml["mysql"]["yaml"],
							:username => yaml["mysql"]["username"], 
							:password=>yaml["mysql"]["password"],
							:database=>"tyrant",
							:reconnect => true )
			@version = yaml["version"]
			@headers = {
	        	        "User-Agent" => yaml["user_agent"],
	                	"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		                "Accept-Language" => "en-us,en;q=0.5",
		                "Accept-Encoding" => "gzip, deflate",
	        	        "Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
		                "Connection" => "keep-alive",
		                "Referer" => "http://kg.tyrantonline.com/Main.swf?#{@version}",
	        	        "Content-Type" => "application/x-www-form-urlencoded"
		        }
		end
		attr_reader :json, :response

		def inflate(string)
	        	zstream = Zlib::GzipReader.new(StringIO.new(string))
		        buf = zstream.read
		        zstream.finish
	        	buf
		end


		def send_request(message, data="")
	
			time = message=="init" ? 0 : Time.now.to_i/(60*15)
			flashcode,auth_token,server,clientcode = "","","",0
			@db.query("SELECT flashcode, auth_token, server, client_code from tyrant_users where user_id=#{@user_id}").each do |r|
				flashcode = r['flashcode']
				auth_token = r['auth_token']
				server = r['server']
				clientcode = r['client_code']
			end

			path = "/api.php?user_id=#{@user_id}&message=#{message}"
			sdata = "#{data}&flashcode=#{flashcode}&time=#{time}&version=#{@version}&hash=#{Digest::MD5.hexdigest(message + time.to_s + "fgjk380vf34078oi37890ioj43")}&ccache=#{}&client_code=#{clientcode}&#{server == "kg" ? "game_" : ""}auth_token=#{auth_token}&rc=2"
			http = Net::HTTP.new("#{server}.tyrantonline.com", 80)
			resp = http.post2(path, sdata, @headers)
			@response = JSON.parse(inflate(resp.body))
		
			if @response.has_key? "duplicate_client"
				@db.query("UPDATE tyrant_users SET issue=1 WHERE user_id=#{@user_id}")
				return {"duplicate_client"=>1}
			end
			return @response
		end
	end
end
