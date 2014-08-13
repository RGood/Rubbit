require 'Rubbit/Reddit_Net_Wrapper'

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
end

class Redditor
	def initialize(json)
		if(json['kind']=='t2')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
	end

	def get_overview(limit=100)
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/.json',limit)
	end

	def get_comments(limit=100)
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/comments.json',limit)
	end

	def get_submitted(limit=100)
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/submitted.json',limit)
	end
end

class ContentGenerator
	include Enumerable
	@limit = nil
	@count = nil
	@source = nil
	@data = nil
	@after = nil
	def initialize(source,limit=100,after='')
		@source = source
		@limit = limit
		@count = 0
		@data = []
		@after = after
	end

	def each
		index = 0
		if(@limit!=nil)
			listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
			if(listing.children[listing.children.length-1]!=nil)
				@after = listing.children[listing.children.length-1].name
			else
				@after = nil
			end
			if(@after == nil)
				@data+=[]
			else
				@data += listing.children
				@count += listing.children.length
			end
		else
			listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+100.to_s+"&after="+@after+"&count="+@count.to_s)
			if(listing.children[listing.children.length-1]!=nil)
				@after = listing.children[listing.children.length-1].name
			else
				@after = nil
			end
			if(@after == nil)
				@data+=[]
			else
				@data += listing.children
				@count+= listing.children.length
			end
		end
		
		while(index<@data.length)
			yield @data[index]
			index+=1
			if(index==@data.length)
				if(@after==nil)
					@after=''
				end
				if(@limit!=nil)
					if(@limit-@count>0)
						listing = Rubbit_Object_Builder.instance.build_listing(@source+'?limit='+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
						if(listing.children[listing.children.length-1]!=nil)
							@after = listing.children[listing.children.length-1].name
						else
							@after = nil
						end
						if(@after == nil)
							@data+=[]
						else
							@data += listing.children
							@count += listing.children.length
						end
					else
						@data += []
					end
				else
					listing = Rubbit_Object_Builder.instance.build_listing(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					puts(@source+"?limit="+100.to_s+"&after="+@after+"&count="+@count.to_s)
					if(listing.children[listing.children.length-1]!=nil)
						@after = listing.children[listing.children.length-1].name
					else
						@after = nil
					end
					if(@after == nil)
						@data+=[]
					else
						@data += listing.children
						@count += listing.children.length
					end
				end
			end
		end
	end

	def [](i)
		return @data[i]
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
		end
	end
end

class Post
	def initialize(json)
		if(json['kind']=='t3')
			data = json['data']
			data.each_key do |k|
				self.class.module_eval {attr_accessor(k)}
				self.send("#{k}=",data[k])
			end
		end
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
				case c['kind']
				when 't1'
					children_objects += [Comment.new(c)]
				when 't2'
					children_objects += [Redditor.new(c)]
				when 't3'
					children_objects += [Post.new(c)]
				when 't4'
					children_objects += [Message.new(c)]
				when 't5'
					children_objects += [Subreddit.new(c)]
				when 'Listing'
					children_objects += [Listing.new(c)]
				end
			end
			@children = children_objects
		end
	end
end