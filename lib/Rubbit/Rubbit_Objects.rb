require 'Rubbit/Reddit_Net_Wrapper'
require 'Rubbit/Rubbit_Exceptions'

class Subreddit
	def initialize(json)
		if(json['kind']=='t5')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
	end

	def get_new(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/new.json',limit)
	end

	def get_hot(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/hot.json',limit)
	end

	def get_top(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/top.json',limit)
	end

	def get_gilded(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/gilded.json',limit)
	end

	def get_rising(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/rising.json',limit)
	end

	def get_controversial(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/controversial.json',limit)
	end

	def submit(title,url=nil,text=nil,kind='self',resubmit=false,save=false,sendreplies=true)
		return Rubbit_Poster.instance.submit(@display_name,title,url,text,kind,resubmit,save,sendreplies)
	end

	def submit_text(title,text=nil,save=false,sendreplies=true)
		return submit(title,nil,text,'self',false,save,sendreplies)
	end

	def submit_link(title,url,save=false,sendreplies=true)
		return submit(title,url,nil,'link',false,save,sendreplies)
	end

	def get_contributors(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/contributors.json',limit)
	end

	def get_banned(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/banned.json',limit)
	end

	def get_moderators(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/moderators.json',limit)
	end

	def add_moderator(name,permissions)
		return Rubbit_Poster.instance.friend('moderator_invite',name,@display_name,permissions)
	end

	def add_contributor(name)
		return Rubbit_Poster.instance.friend('contributor',name,@display_name)
	end

	def ban(name,note,duration)
		return Rubbit_Poster.instance.friend('banned',name,@display_name,note,duration)
	end

	def remove_moderator(name)
		return Rubbit_Poster.instance.unfriend('moderator',name,@display_name)
	end

	def remove_contributor(name)
		return Rubbit_Poster.instance.unfriend('contributor',name,@display_name)
	end

	def unban(name)
		return Rubbit_Poster.instance.unfriend('ban',name,@display_name)
	end
end

class Redditor
	def initialize(json)
		if(json['kind']=='t2')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		elsif(json['id'][0..2]=='t2_')
			data = json
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
	end

	def get_overview(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/.json?sort='+sort,limit)
	end

	def get_comments(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/comments.json?sort='+sort,limit)
	end

	def get_submitted(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/submitted.json?sort='+sort,limit)
	end

	def rebuild
		rebuilt_user = Rubbit_Object_Builder.instance.build_user(@name)
		rebuilt_user.instance_variables.each do |attr_name|
			self.class.module_eval{attr_accessor(attr_name[1..-1])}
			self.send("#{attr_name[1..-1]}=",rebuilt_user.instance_variable_get(attr_name))
		end
	end
end

class ContentGenerator
	include Enumerable
	@limit = nil
	@count = nil
	@source = nil
	@data = nil
	@after = nil
	@modhash = nil
	@index
	def initialize(source,limit=100,after='')
		@source = source
		@limit = limit
		@count = 0
		@data = []
		@after = after
		@index = 0
	end

	def each
		if(@data.length==0)
			if(@limit!=nil)
				if(@limit-@count>0)
					listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
					@after = listing.after
					@data += listing.children
					@count += listing.children.length
				end
			else
				listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+100.to_s+"&after="+@after+"&count="+@count.to_s)
				@after = listing.after
				@data += listing.children
				@count+= listing.children.length
			end
		end
		
		while(@index<@data.length)
			yield @data[@index]
			@index+=1
			if(@index==@data.length)
				if(@after==nil)
					break
				end
				if(@limit!=nil)
					if(@limit-@count>0)
						listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
						@after = listing.after
						@data += listing.children
						@count += listing.children.length
					end
				else
					listing = Rubbit_Object_Builder.instance.build_listing(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					puts(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					@after = listing.after
					@data += listing.children
					@count += listing.children.length
				end
			end
		end
	end

	def [](i)
		return @data[i]
	end

	def next
		if(@index>=@data.length)
			if(@limit!=nil)
					if(@limit-@count>0)
						listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
						@after = listing.after
						@data += listing.children
						@count += listing.children.length
					end
				else
					listing = Rubbit_Object_Builder.instance.build_listing(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					puts(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					@after = listing.after
					@data += listing.children
					@count += listing.children.length
				end
			end
		end
		@index+=1
		return @data[@index-1]
	end

	def reset_generator(i=0)
		@index=i
	end

	def length
		return @data.length
	end
end

class Comment
	def initialize(json)
		if(json['kind']=='t1')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
			children = []
			if(@replies!= nil and @replies['data']!=nil and @replies['data']['children']!=nil)
				@replies['data']['children'].each do |c|
					if(c!=nil)
						children += [Comment.new(c)]
					end
				end
				@replies = children
			end
			if(@replies=="")
				replies = nil
			end
		end
	end

	def reply(text)
		Rubbit_Poster.instance.comment(@name,text)
	end

	def delete
		Rubbit_Poster.instance.delete(@name)
	end

	def edit(text)
		Rubbit_Poster.instance.edit(@name,text)
	end

	def hide
		Rubbit_Poster.instance.hide(@name)
	end
end

class Post
	@comments = nil
	def initialize(json)
		@comments = nil
		if(json['kind']=='t3')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
	end
	def reply(text)
		return Rubbit_Poster.instance.comment(@name,text)
	end

	def replies
		if(@comments==nil)
			@comments = Rubbit_Object_Builder.instance.get_comments('http://www.reddit.com'+@permalink).children
		end
		return @comments
	end

	def delete
		Rubbit_Poster.instance.delete(@name)
	end

	def edit(text)
		Rubbit_Poster.instance.edit(@name,text)
	end

	def hide
		Rubbit_Poster.instance.hide(@name)
	end

	def mark_nsfw
		Rubbit_Poster.instance.mark_nsfw(@name)
	end
end

class Message
	def initialize(json)
		if(json['kind']=='t4')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
	end

	def reply(text)
		Rubbit_Poster.instance.comment(text,@name)
	end
end

class Listing
	@after = nil
	def initialize(json)
		if(json['kind']=='Listing')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
			children_objects = []
			@children.each do |c|
				if(c['id']==nil)
					c['id']='   '
				end
				if(c['kind'] == 't1' or c['id'][0..2]=='t1_')
					children_objects += [Comment.new(c)]
				elsif(c['kind'] == 't2' or c['id'][0..2]=='t2_')
					children_objects += [Redditor.new(c)]
				elsif(c['kind'] == 't3' or c['id'][0..2]=='t3_')
					children_objects += [Post.new(c)]
				elsif(c['kind'] == 't4' or c['id'][0..2]=='t4_')
					children_objects += [Message.new(c)]
				elsif(c['kind'] == 't5' or c['id'][0..2]=='t5_')
					children_objects += [Subreddit.new(c)]
				elsif(c['kind'] == 'Listing')
					children_objects += [Listing.new(c)]
				end
			end
			@children = children_objects
		end
	end
end