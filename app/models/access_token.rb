require 'net/http'
require 'json'

class AccessToken < ApplicationRecord

	def self.gain
		@access_token = AccessToken.new
		uri4 = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx7eb44ce11b9ce817&secret=fd4e5dc0c362526f12371ab0bb2255d1")
	 	http4 = Net::HTTP.new(uri4.host, uri4.port)
	 	http4.use_ssl = true
	 	header = {'content-type'=>'application/json'}
	 	@access_token.value = http4.get(uri4, header).body.split("\"")[3]
	 	@access_token.save

	end
end
