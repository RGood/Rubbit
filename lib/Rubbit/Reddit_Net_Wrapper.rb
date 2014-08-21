require 'net/http'
require 'uri'
require 'time'
require 'json'

class Reddit_Net_Wrapper
	@used = nil
	@remaining = nil
	@reset = nil
	@first_request = nil
	@user_agent = nil

	@cookie = nil

	@@instance = nil

	def self.instance(name=nil)
		if(@@instance==nil)
			if(name!=nil)
				@@instance = new(name)
			else
				return nil
			end
		end
		return @@instance
	end

	def initialize(user)
		@used = 0
		@remaining = 30
		@reset = 60
		@first_request = 0
		@user_agent = 'Rubbit/1.0 Ruby RAW by The1RGood USED BY: '
		@user_agent+=user

		@cookie = ""
	end

	def make_request(request_type,url,params,redirect=false)
		uri = URI(url)

		if(@remaining==0)
			while((Time.now-@first_request).to_i < 60)
			end
		end

		if((Time.now - @first_request).to_i > 60)
			@used = 0
			@remaining = 30
			@reset = 60
			@first_request = Time.now
		end

		if(redirect==false)
			@used += 1
			@remaining -= 1
			@reset = (Time.now - @first_request).to_i
		end

		#puts url

		case request_type.downcase
		when 'post'
			req = Net::HTTP::Post.new uri.request_uri
			req['X-Ratelimit-Used'] = @used
			req['X-Ratelimit-Remaining'] = @remaining
			req['x-Ratelimit-Reset'] = @reset

			req['Cookie']=@cookie

			req.set_form_data(params)

			res = Net::HTTP.start(uri.hostname, uri.port){|http|
				http.request(req)
			}

			if(res.code=='302' or res.code=='301')
				res = make_request(request_type,res['location'],params,true)
			elsif(res['set-cookie']!=nil)
				@cookie = res['set-cookie']
			end

			return res
		when 'get'
			req = Net::HTTP::Get.new uri.request_uri
			req['X-Ratelimit-Used'] = @used
			req['X-Ratelimit-Remaining'] = @remaining
			req['x-Ratelimit-Reset'] = @reset

			req['Cookie']=@cookie

			res = Net::HTTP.start(uri.hostname, uri.port){|http|
				http.request(req)
			}

			if(res.code=='302' or res.code=='301')
				res = make_request(request_type,res['location'],params,true)
			elsif(res['set-cookie']!=nil)
				@cookie=res['set-cookie']
			end

			return res
		when 'delete'
			puts 'delete placeholder'
		else
			puts 'Bad Request Type'
		end
	end

	private_class_method :new
end