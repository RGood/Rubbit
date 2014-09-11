require 'Rubbit/Rubbit_Objects'
require 'Rubbit/Reddit_Net_Wrapper'
require 'Rubbit/Rubbit_Exceptions'
require 'json'

class Rubbit_Object_Builder

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

	def initialize(net_name)
		Reddit_Net_Wrapper.instance(net_name)
	end

	def set_request_period(period)
		return Reddit_Net_Wrapper.instance.set_reset_period(period)
	end

	def build_subreddit(display_name)
		response = Reddit_Net_Wrapper.instance.make_request('get','http://www.reddit.com/r/'+display_name.to_s+"/about.json",{})
		if(response.code=='200')
			return Subreddit.new(JSON.parse(response.body))
		elsif(response.code=='403')
			raise PrivateDataException, "/r/" + display_name + " is a private subreddit."
		elsif(response.code=='404')
			raise InvalidSubredditException, "/r/" + display_name + " does not exist."
		end
	end

	def build_user(user)
		response = Reddit_Net_Wrapper.instance.make_request('get','http://www.reddit.com/user/'+user.to_s+'/about.json',{})
		if(response.code=='200')
			return Redditor.new(JSON.parse(response.body))
		else
			raise InvalidUserException, "User unable to be retrieved"
		end
	end

	def build_listing(link)
		response = Reddit_Net_Wrapper.instance.make_request('get',link,{})
		if(response.code=='200')
			return Listing.new(JSON.parse(response.body,:max_nesting => 100))
		end
		return nil
	end

	def build_submission(link)
		response = Reddit_Net_Wrapper.instance.make_request('get',link.to_s+".json",{})
		if(response.code=='200')
			json = JSON.parse(response.body,:max_nesting=>100)
			if(json['kind']=='t1')
				return Comment.new(json)
			elsif(json['kind']=='t3')
				return Post.new(json)
			elsif(json['kind']=='t4')
				return Message.new(json)
			else
				raise InvalidSubmissionException, "Could not get submission"
			end
		end
	end

	def get_comments(link,limit)
		return ContentGenerator.new(link,limit)
	end

	private_class_method :new
end

class Rubbit_Poster
	@@instance = nil
	@logged_in_user = nil

	def initialize(net_name)
		Reddit_Net_Wrapper.instance(net_name)
		@logged_in_user = nil
	end

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

	def login(user,passwd)
		params = {}
		params['op']='login'
		params['user']=user
		params['passwd']=passwd
		params['api-type']='json'
		
		login_status = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/login/',params).code

		if(login_status=='200')
			user = Rubbit_Object_Builder.instance.build_user(user)
			@logged_in_user = user.name
			return user
		else
			raise InvalidUserException, "Could not validate login credentials"
		end
	end

	def clear_sessions(curpass)
		params = {}
		params['api_type']='json'
		params['curpass'] = curpass
		params['uh']=get_modhash

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/clear_sessions/',params)

		return response.body
	end

	def delete_user(user,passwd,message,confirm)
		params = {}
		params['api_type']='json'
		params['user']=user
		params['passwd']=passwd
		params['message']=message
		params['uh']=get_modhash

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/delete_user/',params)
		return response.body
	end

	def update(email,newpass,curpass,verify,verpass)
		params = {}
		params['api_type']='json'
		params['curpass']=curpass
		params['email']=email
		params['newpass']=newpass
		params['verify']=verify
		params['verpass']=verpass
		params['uh']=get_modhash

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/update/',params)
		return response.body
	end

	def submit(sr,title,url=nil,text=nil,kind='self',resubmit=nil,save=false,sendreplies=true)
		params = {}
		params['api_type']='json'
		params['extension']=nil
		params['kind']=kind
		params['resubmit']=resubmit
		params['save']=save
		params['sendreplies']=sendreplies
		params['id']='#newlink'
		params['sr']=sr
		params['r']=sr
		params['text']=text
		params['title']=title
		params['uh']=get_modhash
		params['url']=url

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/submit/',params)
		return JSON.parse(response.body)
	end

	def comment(parent,text)
		params = {}
		params['text']=text
		params['thing_id']=parent
		params['uh']=get_modhash
		params['renderstylel']='html'

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/comment',params)

		return response.body
	end

	def hide(id)
		params = {}
		params['id'] = id
		params['uh']=get_modhash
		
		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/hide',params)

		return response.body
	end

	def delete(id)
		params = {}
		params['id'] = id
		params['uh']=get_modhash
		
		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/del',params)

		return response.body
	end

	def edit(id,text)
		params = {}
		params['api_type']='json'
		params['text']=text
		params['id'] = id
		params['uh']=get_modhash
		
		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/editusertext',params)

		return response.body
	end

	def mark_nsfw(id)
		params = {}
		params['id'] = id
		params['uh']=get_modhash
		
		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/marknsfw',params)

		return response.body
	end

	def friend(type,user,container,info=nil,duration=nil)
		params = {}
		params['api_type']='json'
		params['type']=type
		params['name']=user
		params['modhash']=get_modhash
		case type
		when 'friend'
			params['note']=info
			params['container']=container
		when 'moderator'
			params['container']=container
			params['permissions']=info
		when 'moderator_invite'
			params['container']=container
			params['permissions']=info
		when 'contributor'
			params['container']=container
		when 'banned'
			params['container']=container
			params['note']=info
			params['duration']=duration
		when 'wikibanned'
			params['container']=container
			params['note']=info
			params['duration']=duration
		when 'wikicontributor'
			params['container']=container
		end

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/friend',params)

		return response.body
	end

	def unfriend(type,user,container)
		params = {}
		params['api_type']='json'
		params['type']=type
		params['name']=user
		params['modhash']=get_modhash
		params['container']=container

		response = Reddit_Net_Wrapper.instance.make_request('post','http://www.reddit.com/api/unfriend',params)

		return response.body
	end

	def get_modhash
		response = Reddit_Net_Wrapper.instance.make_request('get','http://www.reddit.com/user/'+@logged_in_user+'/about.json',{})
		data = JSON.parse(response.body)
		return data['data']['modhash']
	end

	private_class_method :new
end