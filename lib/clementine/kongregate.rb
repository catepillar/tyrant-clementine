module Clementine
	class Kongregate

		@http = Net::HTTP.new('www.kongregate.com', 80)

		def self.lookup_name(name)
			resp = JSON.parse(@http.get("/api/user_info.json?username=#{name}").body)
			if resp.has_key? "user_id"
				return resp["user_id"]
			else
				return nil
			end
		end
	end
end