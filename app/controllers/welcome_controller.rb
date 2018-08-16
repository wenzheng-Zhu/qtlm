require 'net/http'
require 'json'

class WelcomeController < ApplicationController

    skip_before_action :verify_authenticity_token, only: [:shixian, :bar] 

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
        	   data2 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>'若喜欢我们的课程，请扫一扫即将发给您的二维码免费领取会员卡后才能下单购买，并且可以享受积分政策，满1200分赠送一次课程的优惠哦！'} }).to_json
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


                #给这个用户tag_id

                  uri11 = URI("https://api.weixin.qq.com/cgi-bin/tags/members/batchtagging?access_token=" + "#{access_token_value}")
                  http11 = Net::HTTP.new(uri11.host, uri11.port)
                  http11.use_ssl = true
                  data11 = {"openid_list" => ["#{open_id}"], "tagid" => "100"}.to_json
                  header = {'content-type'=>'application/json'}
                  http11.post(uri11, data11, header)
          else
        	#在rails里已经保存过该用户
        	#判断在微信公众号里是不是会员，其实就是看有没有领会员卡，如果领了，更新积分，满积分送课程券。如果没有领，推送领卡二维码
        	# if form_type == "d8LkpV"
               uri6 = URI("https://api.weixin.qq.com/card/user/getcardlist?access_token=" + "#{access_token_value}")
                http6 = Net::HTTP.new(uri6.host, uri6.port)
                http6.use_ssl = true
                data6 = {"openid" => "#{open_id}", "card_id"=>"pIFqF1cZRAJ_yq471tJwcoa_pw9M"}.to_json
                header = {'content-type'=>'application/json'}
                res = http6.post(uri6, data6, header).body.split("\"")
            if !(res[8] == ":[],")
               wxuser = WxUser.find_by(open_id: open_id)
               wxuser.update_attributes(bonus: (wxuser.bonus + total_price.to_i))
               wxuser.save

                  wxuser_t = WxUser.find_by(open_id: open_id)
                  wxuser_t.update_attributes(member: true)
                  wxuser_t.save
              #推送该会员查看已买商品的链接
               # uri3 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
               # http3 = Net::HTTP.new(uri3.host, uri3.port)
               # http3.use_ssl = true
               # data3 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"<a href="http://212.64.11.106/foo?openid="#{open_id}"">查看已购课程</a>" } }).to_json
               # header = {'content-type'=>'application/json'}
               # http3.post(uri3, data3, header)


               #查看会员积分，并分等级 1-1200:小萌 1201-5000:萌太 5000+：萌主
                wxuser_new = WxUser.find_by(open_id: open_id)
                if wxuser_new.bonus <= 1200
                  wxuser_new.rank = "小萌"
                  wxuser_new.save
                elsif wxuser_new.bonus > 5000
                  wxuser_new.rank = "萌主"
                  wxuser_new.save
                else
                  wxuser_new.rank = "萌太"
                  wxuser_new.save
                end
               # if wxuser_new.bonus >= 2
               #   card_given_amounts = wxuser_new.bonus/2
               #   wxuser_new.update_attributes(bonus: (wxuser_new.bonus - (wxuser_new.bonus/2)*2))
               #   wxuser_new.save

               #   uri11 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
               #      http11 = Net::HTTP.new(uri11.host, uri11.port)
               #      http11.use_ssl = true
               #      data11 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"亲爱的会员，根据会员享有的权益，根据您的积分，您将得到#{card_given_amounts}次赠送课程，请扫描以下二维码获取,系统将自动抵扣您的积分，谢谢！：）"} }).to_json
               #      header = {'content-type'=>'application/json'}
               #      http11.post(uri11, data11, header)
               #  card_given_amounts.times do
               #     uri4 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
               #     http4 = Net::HTTP.new(uri4.host, uri4.port)
               #     http4.use_ssl = true
               #     data4 = ({'touser'=>"#{open_id}", 'msgtype'=>'image', 'image'=>{'media_id'=>'RL0eNhKUSH_Y6no5oTlM8hnn8j71Josa6bb6F3wZLoE'}}).to_json
               #     header = {'content-type'=>'application/json'}
               #     http4.post(uri4, data4, header)
               #    end  



                #把bonus推送到微信后台，刷新会员积分
                uri5 = URI("https://api.weixin.qq.com/card/membercard/updateuser?access_token=" + "#{access_token_value}")
                http5 = Net::HTTP.new(uri5.host, uri5.port)
                http5.use_ssl = true
                data5 = {'code' => "#{user_code}", 'card_id' => 'pIFqF1cZRAJ_yq471tJwcoa_pw9M', 'bonus' => "#{wxuser_new.bonus}".to_i, 'custom_field_value1' => "#{wxuser_new.rank}" }.to_json
                header = {'content-type'=>'application/json'}
                http5.post(uri5, data5, header)	
               end

               #推送会员查看购买记录的链接
               uri12 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
               http12 = Net::HTTP.new(uri12.host, uri12.port)
               http12.use_ssl = true
               # data12 = {'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"<a href= 'http://212.64.11.106/foo?openid=#{open_id}' >点击查看已购课程</a>" } }.to_json
               data12 = {'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"点击 http://212.64.11.106/foo?openid=#{open_id} 查看已购课程" } }.to_json
               header = {'content-type'=>'application/json'}
               http12.post(uri12, data12, header)
        	   else

        	    #如果没有领过，推送领会员卡二维码	
        	    #推送扫码加入会员消息，并带上会员卡会员优惠信息
                    uri8 = URI("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + "#{access_token_value}")
                    http8 = Net::HTTP.new(uri8.host, uri8.port)
                    http8.use_ssl = true
                    data8 = ({'touser'=>"#{open_id}", 'msgtype'=>'text', 'text'=>{'content'=>"请扫一扫即将发给您的二维码免费领取会员卡，凭会员卡才能参加您已购买的凭证；领卡后，您以后消费可积分，且可享受满1200积分送一次的优惠，快行动吧！"} }).to_json
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

         render json: {status: 200}, status: :ok

    end

      def bar
        @orders = Order.where(open_id: params[:openid])
        @arr = []
        @arr_elecount = []
        @arr_new = []

        @orders.each do |od| 
         @arr << (od.stuff.split("\"")[3])
         end 

        @arr_new = @arr.uniq.compact

        @arr_new.each do |ar|
          @arr_elecount << @arr.count(ar)
        end

       @arr 
       @arr_new
       @arr_elecount
       @k = @arr_new.count-1

      end


      def zheng

      end

      def wen
      end

    
end



   