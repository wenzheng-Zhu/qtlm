require 'net/http'
require 'json'

class WelcomeController < ApplicationController

    def make

    	#判断从金数据那边推送过的open_id在rails后台数据库wxusers里是不是存在
        arrwen = []
    	WxUser.all&.each do |wu|
	 		if wu.open_id == params[:entry][:x_field_weixin_openid]
	 			arrwen << false
	 		else
	 			arrwen << true
	 		end
	 	end


    	access_token_value = (AccessToken.last)&.value

    	open_id = params[:entry][:x_field_weixin_openid]
    	phone = params[:entry][:field_2]
    	total_price = params[:entry][:total_price]
    	sum_price = params[:entry][:sum_price]
    	stuff = params[:entry][:field_1]
        Order.create(open_id: open_id, total_price: total_price, sum_price: sum_price, stuff: stuff)



         #如果在rails里没保存过该用户
        if !(arrwen.include?false)

        	#推送扫码加入会员消息，并带上会员卡会员优惠信息
        	uri2 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
        	http2 = Net::HTTP.new(uri2.host, uri2.port)
        	http2.use_ssl = true
        	data2 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>'be a member, having discount!'} }).to_json
        	header = {'content-type'=>'application/json'}
        	http2.post(uri2, data2, header)
        	#推送会卡二维码，扫码加入会员
        	uri = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
        	http = Net::HTTP.new(uri.host, uri.port)
        	http.use_ssl = true
        	data = ({'touser'=>"#{open_id}", 'msgtype'=>'image', 'image'=>{'media_id'=>'RL0eNhKUSH_Y6no5oTlM8lx2EndoR91fHvfGz63cCAQ'}}).to_json
        	header = {'content-type'=>'application/json'}
            http.post(uri, data, header)

            #保存在rails数据库里
        	WxUser.create(open_id: open_id, phone: phone, member: false, bonus: 0)
        else

        	#在rails里已经保存过该用户
        	#判断在微信公众号里是不是会员，如果从金数据那边推送过来的信息里有sum_price,说明该用户有tagid, 是会员，那么更新该用户在rails中的么 member属性为true，并且更新在微信后台里的会员卡积分
        	if sum_price

        		wxuser = WxUser.find_by(open_id: open_id)
        		wxuser.update_attributes(bonus: wxuser.bonus + total_price, member: true)
        		wxuser.save

        		#向微信后台服务器发送请求，获取该用户的会员卡code属性
        		uri3 = URI("https://api.weixin.qq.com/card/user/getcardlist?access_token=" + "#{access_token_value}")
        		http3 = Net::HTTP.new(uri3.host, uri3.port)
        		http3.use_ssl = true
        		data3 = { 'openid'=>"#{open_id}", "card_id"=>"pIFqF1cZRAJ_yq471tJwcoa_pw9M"}.to_json
        		header = {'content-type'=>'application/json'}
        		response = http3.post(uri3, data3, header)
        		arr = response.body.split("\"").uniq

        		arrzheng = []

        		arr.each_with_index do |item, index|
        			arrzheng << index  if item == "code"
        		end

        		user_code = arr[arrzheng[0]+1]


        		#把bonus推送到微信后台，刷新会员积分
        		uri = URI("https://api.weixin.qq.com/card/membercard/updateuser?access_token=" + "#{access_token_value}")
        		http = Net::HTTP.new(uri.host, uri.port)
        		http.use_ssl = true
        		data = {'code' => "#{user_code}", 'card_id' => 'pIFqF1cZRAJ_yq471tJwcoa_pw9M', 'bonus' => "#{total_price}"}.to_json
        		header = {'content-type'=>'application/json'}
        		http.post(uri, data, header)
        	else

        		#如果没有sum_price,说明这个用户在微信里没有tagid，不是会员。先判断这个用户有没有领会员卡，如果领了，赋予该用户在微信后台的tagid,如果没有，不是会员，不更新积分
        		uri5 = URI("https://api.weixin.qq.com/card/user/getcardlist?access_token=" + "#{access_token_value}")
        		http5 = Net::HTTP.new(uri5.host, uri5.port)
        		http5.use_ssl = true
        		data5 = {"openid" => "#{open_id}", "card_id"=>"pIFqF1cZRAJ_yq471tJwcoa_pw9M"}.to_json
        		header = {'content-type'=>'application/json'}
        		res = http5.post(uri5, data5, header).body.split("\"")
        		if !(res[8] == ":[],")
        		  uri6 = URI("https://api.weixin.qq.com/cgi-bin/tags/members/batchtagging?access_token=" + "#{access_token_value}")
        		  http6 = Net::HTTP.new(uri6.host, uri6.port)
        		  http6.use_ssl = true
        		  data6 = {"openid_list" => ["#{open_id}"], "tagid" => "100"}.to_json
        		  header = {'content-type'=>'application/json'}
        		  http6.post(uri6, data6, header)
        		end
        	end


        end
    end


    def fuck

        uri4 = URI("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx7eb44ce11b9ce817&secret=fd4e5dc0c362526f12371ab0bb2255d1")
        http4 = Net::HTTP.new(uri4.host, uri4.port)
        http4.use_ssl = true
        header = {'content-type'=>'application/json'}
        @test = http4.get(uri4, header).body.split("\"")[3]
        
    end
    
end



