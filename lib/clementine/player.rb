module Clementine
	class Player

		def initialize(opts = {})
			$mutex ||= Mutex.new		#fancy ruby trick
			@user_id=opts[:user_id].to_i
			@db = opts[:db]
			@version = opts[:version]
			@headers = {
	        	        "User-Agent" => opts[:user_agent],
	                	"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
		                "Accept-Language" => "en-us,en;q=0.5",
		                "Accept-Encoding" => "gzip, deflate",
	        	        "Accept-Charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.7",
		                "Connection" => "keep-alive",
		                "Referer" => "http://kg.tyrantonline.com/Main.swf?#{@version}",
	        	        "Content-Type" => "application/x-www-form-urlencoded"
		        }
			@t = Thread.new {}
		end
		attr_reader :json, :response, :t, :user_id

		def inflate(string)
			zstream = Zlib::GzipReader.new(StringIO.new(string))
			buf = zstream.read
			zstream.finish
			buf
		end

		def prep_data(message, data)
			time = message=="init" ? 0 : Time.now.to_i/(60*15)

			flashcode,auth_token,server,clientcode = "","","",0
			@db.query("SELECT flashcode, auth_token, server, client_code from tyrant_users where user_id=#{@user_id}").each do |r|
				flashcode = r['flashcode']
				auth_token = r['auth_token']
				server = r['server']
				clientcode = r['client_code']
			end

			string = "#{data}"
			string << "&flashcode=#{flashcode}"
			string << "&time=#{time}"
			string << "&version=#{@version}"
			string << "&hash=#{Digest::MD5.hexdigest(message + time.to_s + "fgjk380vf34078oi37890ioj43")}"
			string << "&ccache=#{}"
			string << "&client_code=#{clientcode}"
			string << "&#{server == "kg" ? "game_" : ""}auth_token=#{auth_token}"
			string << "&rc=2"

			return [string, server]
		end


		def send_request(message, data="")

			unless @t.nil?
				if @t.alive?
					return {"duplicate_client"=>1}
				end
				@t.join
			end

			path = "/api.php?user_id=#{@user_id}&message=#{message}"
			sdata,server = prep_data(message, data)
			http = Net::HTTP.new("#{server}.tyrantonline.com", 80)
			resp = http.post2(path, sdata, @headers)
			@response = JSON.parse(inflate(resp.body))

			if @response.has_key? "duplicate_client"
				@t = Thread.new do
					if $mutex.try_lock
						find_client_code()
						$mutex.unlock
					end
				end
				return {"duplicate_client"=>1}
			end
			return @response
		end

		def find_client_code()

			puts "Finding client code"

			codes = (0..1000).to_a.shuffle		#randomize the code order, mostly for fun.
			time = Time.now.to_i/(60*15)

			flashcode,auth_token,server,clientcode = "","","",0
			@db.query("SELECT flashcode, auth_token, server, client_code from tyrant_users where user_id=#{@user_id}").each do |r|
				flashcode = r['flashcode']
				auth_token = r['auth_token']
				server = r['server']
				clientcode = r['client_code']
			end

			response = {}
			clientcode = 0

			for index in 0..1000
				path = "/api.php?user_id=#{@user_id}&message=getName"		#random api call here.  Picked because return packet size is small
				http = Net::HTTP.new("#{server}.tyrantonline.com", 80)

				clientcode = codes[index]
				sdata = "?target_id=#{@user_id}"
				sdata << "&flashcode=#{flashcode}"
				sdata << "&time=#{time}"
				sdata << "&version=#{@version}"
				sdata << "&hash=#{Digest::MD5.hexdigest("getName" + time.to_s + "fgjk380vf34078oi37890ioj43")}"
				sdata << "&ccache=#{}"
				sdata << "&client_code=#{clientcode}"
				sdata << "&#{server == "kg" ? "game_" : ""}auth_token=#{auth_token}"
				sdata << "&rc=2"

				response = JSON.parse(inflate(http.post2(path, sdata,@headers).body))
				break unless response.has_key? "duplicate_client"
			end

			puts "\r\e[0KFound client code. #{clientcode}"
			@db.query("UPDATE tyrant_users SET client_code=#{clientcode}, issue=0 WHERE user_id=#{@user_id}")
		end
	end
end
