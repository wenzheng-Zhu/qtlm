require 'net/http'
require 'json'

class WelcomeController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:shixian] 

 def shixian

    	#判断从金数据那边推送过的open_id在rails后台数据库wxusers里是不是存在
        arrwen = []
    	WxUser.all&.each do |wu|
	 		if wu.open_id == params[:entry][:x_field_weixin_openid]
	 			arrwen << false
	 		else
	 			arrwen << true
	 		end
	 	end

       
       # cookies[:open_id] = params[:entry][:x_field_weixin_openid]
    	access_token_value = (AccessToken.last)&.value
        form_type = params[:form]
    	open_id = params[:entry][:x_field_weixin_openid]
    	phone = params[:entry][:field_2]
    	total_price = params[:entry][:total_price]
    	sum_price = params[:entry][:sum_price]
    	stuff = params[:entry][:field_1]
        Order.create(open_id: open_id, total_price: total_price, sum_price: sum_price, stuff: stuff)


         uri10 = URI("https://api.weixin.qq.com/card/user/getcardlist?access_token=" + "#{access_token_value}")
                http10 = Net::HTTP.new(uri10.host, uri10.port)
                http10.use_ssl = true
                data10 = {"openid" => "#{open_id}", "card_id"=>"pIFqF1cZRAJ_yq471tJwcoa_pw9M"}.to_json
                header = {'content-type'=>'application/json'}
                res = http10.post(uri10, data10, header).body.split("\"").uniq
        user_code = res[12]



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
            
                # WxUser.create(open_id: open_id, phone: phone, member: true, bonus: total_price.to_i)
                # wu_new = WxUser.find_by(open_id: open_id)
                #  if wu_new.bonus >= 1
                #    wu_new.update_attributes(bonus: (wu_new.bonus - (wu_new.bonus/1)*1))
                #    wu_new.save
                #    (wu_new.bonus/1).times do
                #      uri3 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
                #      http3 = Net::HTTP.new(uri3.host, uri3.port)
                #      http3.use_ssl = true
                #      data3 = ({'touser'=>"#{open_id}", 'msgtype'=>'image', 'image'=>{'media_id'=>'RL0eNhKUSH_Y6no5oTlM8lx2EndoR91fHvfGz63cCAQ'}}).to_json
                #      header = {'content-type'=>'application/json'}
                #      http.post(uri3, data3, header)
                #     end
                #  end
            
        else
        	#在rails里已经保存过该用户
        	#判断在微信公众号里是不是会员，如果从金数据那边推送过来的信息中 form_type的值是"d8LkpV",说明该用户有tagid, 是会员，那么更新该用户在rails中的么 member属性为true，并且更新在微信后台里的会员卡积分
        	if form_type == "d8LkpV"
               wxuser = WxUser.find_by(open_id: open_id)
               wxuser.update_attributes(bonus: (wxuser.bonus + total_price.to_i))
               wxuser.save
              #推送该会员查看已买商品的链接
               # uri3 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
               # http3 = Net::HTTP.new(uri3.host, uri3.port)
               # http3.use_ssl = true
               # data3 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"<a href="http://212.64.11.106/foo?openid="#{open_id}"">查看已购课程</a>" } }).to_json
               # header = {'content-type'=>'application/json'}
               # http3.post(uri3, data3, header)
                wxuser_new = WxUser.find_by(open_id: open_id)
               if wxuser_new.bonus >= 1
                 card_given_amounts = wxuser_new.bonus/1
                wxuser_new.update_attributes(bonus: (wxuser_new.bonus - (wxuser_new.bonus/1)*1))
                wuuser_new.save
                card_given_amounts.times do
                   uri4 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
                   http4 = Net::HTTP.new(uri4.host, uri4.port)
                   http4.use_ssl = true
                   data4 = ({'touser'=>"#{open_id}", 'msgtype'=>'image', 'image'=>{'media_id'=>'RL0eNhKUSH_Y6no5oTlM8lx2EndoR91fHvfGz63cCAQ'}}).to_json
                   header = {'content-type'=>'application/json'}
                   http4.post(uri4, data4, header)
                  end  
                end

                #把bonus推送到微信后台，刷新会员积分
                uri5 = URI("https://api.weixin.qq.com/card/membercard/updateuser?access_token=" + "#{access_token_value}")
                http5 = Net::HTTP.new(uri5.host, uri5.port)
                http5.use_ssl = true
                data5 = {'code' => "#{user_code}", 'card_id' => 'pIFqF1cZRAJ_yq471tJwcoa_pw9M', 'bonus' => "#{wxuser.bonus}".to_i }.to_json
                header = {'content-type'=>'application/json'}
                http5.post(uri5, data5, header)	
        	else

        		#如果form_type不是"d8LkpV",说明这个用户在微信里没有tagid，不是会员。先判断这个用户有没有领会员卡，如果领了，赋予该用户在微信后台的tagid,如果没有，不是会员，不更新积分，如果没有领，推送会员卡二维码并且带上会员卡优惠信息
        		uri6 = URI("https://api.weixin.qq.com/card/user/getcardlist?access_token=" + "#{access_token_value}")
        		http6 = Net::HTTP.new(uri6.host, uri6.port)
        		http6.use_ssl = true
        		data6 = {"openid" => "#{open_id}", "card_id"=>"pIFqF1cZRAJ_yq471tJwcoa_pw9M"}.to_json
        		header = {'content-type'=>'application/json'}
        		res = http6.post(uri6, data6, header).body.split("\"")
        		 if !(res[8] == ":[],")
        		  uri7 = URI("https://api.weixin.qq.com/cgi-bin/tags/members/batchtagging?access_token=" + "#{access_token_value}")
        		  http7 = Net::HTTP.new(uri7.host, uri7.port)
        		  http7.use_ssl = true
        		  data7 = {"openid_list" => ["#{open_id}"], "tagid" => "100"}.to_json
        		  header = {'content-type'=>'application/json'}
        		  http7.post(uri7, data7, header)
                  wxuser_t = WxUser.find_by(open_id: open_id)
                  wxuser_t.update_attributes(member: true)
                  wxuser_t.save
                  else
                    #推送扫码加入会员消息，并带上会员卡会员优惠信息
                    uri8 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
                    http8 = Net::HTTP.new(uri8.host, uri8.port)
                    http8.use_ssl = true
                    data8 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>'be a member, having discount!'} }).to_json
                    header = {'content-type'=>'application/json'}
                    http8.post(uri8, data8, header)
                   #推送会卡二维码，扫码加入会员
                    uri9 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
                    http9 = Net::HTTP.new(uri9.host, uri9.port)
                    http9.use_ssl = true
                    data9 = ({'touser'=>"#{open_id}", 'msgtype'=>'image', 'image'=>{'media_id'=>'RL0eNhKUSH_Y6no5oTlM8lx2EndoR91fHvfGz63cCAQ'}}).to_json
                    header = {'content-type'=>'application/json'}
                    http9.post(uri9, data9, header)
         		  end
        	end



        end

      end
    
    end



   