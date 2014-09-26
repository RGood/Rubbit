require 'Rubbit/Reddit_Net_Wrapper'
require 'Rubbit/Rubbit_Exceptions'

# == Rubbit Object
#
# Object Representing a Subreddit.
#
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

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the new queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_new(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/new.json',limit)
	end

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the hot queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_hot(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/hot.json',limit)
	end

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the top queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_top(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/top.json',limit)
	end

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the gilded queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_gilded(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/gilded.json',limit)
	end

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the rising queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_rising(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/rising.json',limit)
	end

	# ==== Description
	# 
	# Returns enumerable ContentGenerator object representing the controversial queue
	# 
	# ==== Attributes
	# 
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_controversial(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/controversial.json',limit)
	end

	
	# ==== Description
	#
	# General function for submitting content to a subreddit
	#
	# ==== Attributes
	#
	# * +title+ - *REQUIRED.* Title for post. Cannot be empty or the function will not work.
	# * +url+ - The url for the post. Will only be used if kind is "link"
	# * +text+ - The text for the post. Will only be used if kind is "self"
	# * +kind+ - Determines type of post. Either link or self.
	# * +resubmit+ - If true, will make post to subreddit regardless if it is a repost
	# * +save+ - Will save the post in user's "saved" links if true
	# * +sendreplies+ - Will send replies to post to user's inbox by default, unless this is set to false
	#
	def submit(title,url=nil,text=nil,kind='self',resubmit=false,save=false,sendreplies=true)
		return Rubbit_Poster.instance.submit(@display_name,title,url,text,kind,resubmit,save,sendreplies)
	end

	# ==== Description
	#
	# Function for submitting self posts to a subreddit.
	#
	# ==== Attributes
	#
	# * +title+ - *REQUIRED.* Title for post. Cannot be empty or the function will not work.
	# * +text+ - The text for the post.
	# * +save+ - Will save the post in user's "saved" links if true
	# * +sendreplies+ - Will send replies to post to user's inbox by default, unless this is set to false
	#
	def submit_self(title,text=nil,save=false,sendreplies=true)
		return submit(title,nil,text,'self',false,save,sendreplies)
	end

	# ==== Description
	#
	# Function for submitting link posts to a subreddit.
	#
	# ==== Attributes
	#
	# * +title+ - *REQUIRED.* Title for post. Cannot be empty or the function will not work.
	# * +url+ - The url for the post.
	# * +resubmit+ - If true, will make post to subreddit regardless if it is a repost
	# * +save+ - Will save the post in user's "saved" links if true
	# * +sendreplies+ - Will send replies to post to user's inbox by default, unless this is set to false
	#
	def submit_link(title,url,resubmit=false,save=false,sendreplies=true)
		return submit(title,url,nil,'link',resubmit,save,sendreplies)
	end

	# ==== Description
	#
	# Returns enumerable ContentGenerator object representing approved contributors to a subreddit
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_contributors(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/contributors.json',limit)
	end

	
	# ==== Description
	#
	# Returns enumerable ContentGenerator object representing banned users of a subreddit. Will only work if subreddit moderator.
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_banned(limit=100)
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/banned.json',limit)
	end

	
	# ==== Description
	#
	# Returns enumerable ContentGenerator object representing moderators of a subreddit. Will only work if subreddit is viewable.
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the returned ContentGenerator will hold. For no limit, use *nil*
	#
	def get_moderators
		return ContentGenerator.new('http://www.reddit.com/r/'+@display_name.to_s+'/about/moderators.json',nil)
	end

	
	# ==== Description
	#
	# Function for adding moderator to a subreddit. Only works if subreddit moderator.
	#
	# ==== Attributes
	#
	# * +name+ - name of user to add as a moderator
	# * +permissions+ - string containing permissions to give this user
	#
	def add_moderator(name,permissions)
		return Rubbit_Poster.instance.friend('moderator_invite',name,@display_name,permissions)
	end

	# ==== Description
	#
	# Function for adding contributor to a subreddit. Only works if subreddit moderator.
	# ==== Attributes
	#
	# * +name+ - name of user to add as a contributor
	#
	def add_contributor(name)
		return Rubbit_Poster.instance.friend('contributor',name,@display_name)
	end

	# ==== Description
	#
	# Function for banning a user from a subreddit. Only works if subreddit moderator.
	#
	# ==== Attributes
	#
	# * +name+ - name of user to ban
	# * +note+ - note for the ban
	# * +duration+ - length of period they are banned for, in days. Send *nil* for permanent
	#
	def ban(name,note,duration)
		return Rubbit_Poster.instance.friend('banned',name,@display_name,note,duration)
	end

	# ==== Description
	#
	# Function for removing a moderator from a subreddit. Only works if subreddit moderator and has higher permissions than mod to remove.
	#
	# ==== Attributes
	#
	# * +name+ - name of moderator to remove
	#
	def remove_moderator(name)
		return Rubbit_Poster.instance.unfriend('moderator',name,@display_name)
	end

	# ==== Description
	#
	# Function for removing a contributor from a subreddit. Only works if subreddit moderator.
	#
	# ==== Attributes
	#
	# * +name+ - name of contributor to remove
	#
	def remove_contributor(name)
		return Rubbit_Poster.instance.unfriend('contributor',name,@display_name)
	end

	# ==== Description
	#
	# Function for unbanning a user from a subreddit. Only works if subreddit moderator.
	#
	# ==== Attributes
	#
	# * +name+ - name of user to unban
	#
	def unban(name)
		return Rubbit_Poster.instance.unfriend('ban',name,@display_name)
	end
end

# == Rubbit Object
#
# Object Representing a Redditor.
# If the requested Redditor is logged in, this object also contains a modhash.
# If obtained from a subreddit list, this object will need to be rebuilt using the rebuild function
#
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

	# ==== Description
	#
	# Function for getting user overview content from a profile, including both comments and posts
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the ContentGenerator can contain
	# * +sort+ - Sort order by which the content is returned
	#
	def get_overview(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/.json?sort='+sort,limit)
	end

	# ==== Description
	#
	# Function for getting user comment from a profile
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the ContentGenerator can contain
	# * +sort+ - Sort order by which the content is returned
	#
	def get_comments(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/comments.json?sort='+sort,limit)
	end

	# ==== Description
	#
	# Function for getting user posts from a profile
	#
	# ==== Attributes
	#
	# * +limit+ - Maximum entries that the ContentGenerator can contain
	# * +sort+ - Sort order by which the content is returned
	#
	def get_submitted(limit=100,sort='new')
		return ContentGenerator.new('http://www.reddit.com/user/'+@name.to_s+'/submitted.json?sort='+sort,limit)
	end

	# ==== Description
	#
	# Function for rebuilding user object using data from their profile page
	#
	def rebuild
		rebuilt_user = Rubbit_Object_Builder.instance.build_user(@name)
		rebuilt_user.instance_variables.each do |attr_name|
			self.class.module_eval{attr_accessor(attr_name[1..-1])}
			self.send("#{attr_name[1..-1]}=",rebuilt_user.instance_variable_get(attr_name))
		end
	end
end

# == Rubbit Object
#
# Enumerable object that allows a user to iterate over data sets
#
class ContentGenerator
	include Enumerable
	@limit = nil
	@count = nil
	@source = nil
	@data = nil
	@after = nil
	@modhash = nil
	@index
	@limit_param

	# ==== Description
	#
	# Initializes a ContentGenerator Object
	#
	# ==== Attributes
	#
	# * +source+ - *Required.* Link to the .json page for the content
	# * +limit+ - Maximum number of entries the ContentGenerator will load. *nil* for no limit.
	# * +after+ - ID of entry to load content after.
	#
	def initialize(source,limit=100,after='')
		@source = source
		@limit = limit
		@count = 0
		@data = []
		@after = after
		@index = 0
		if(@source.include?('?'))
			@limit_param = '&limit='
		else
			@limit_param = '?limit='
		end
	end

	# ==== Description
	#
	# Iterates over the content from a specific source until there is no content left or until a limit is reached
	#
	def each
		if(@data.length==0)
			if(@limit!=nil)
				if(@limit-@count>0)
					listing = Rubbit_Object_Builder.instance.build_listing(@source+@limit_param+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
					@after = listing.after
					@data += listing.children
					@count += listing.children.length
				end
			else
				listing = Rubbit_Object_Builder.instance.build_listing(@source+@limit_param+100.to_s+"&after="+@after+"&count="+@count.to_s)
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
						listing = Rubbit_Object_Builder.instance.build_listing(@source+@limit_param+[@limit-@count,100].min.to_s+"&after="+@after+"&count="+@count.to_s)
						@after = listing.after
						@data += listing.children
						@count += listing.children.length
					end
				else
					listing = Rubbit_Object_Builder.instance.build_listing(@source+@limit_param+100.to_s+"&after="+@after+"&count="+@count.to_s)
					puts(@source+@limit_param+100.to_s+"&after="+@after+"&count="+@count.to_s)
					@after = listing.after
					@data += listing.children
					@count += listing.children.length
				end
			end
		end
	end

	# ==== Description
	#
	# Returns an object in the ContentGenerator at a particular index. Only works after it has been iterated through and loaded.
	#
	# ==== Attributes
	#
	# * +index+ - The index of the object in the ContentGenerator that will be returned.
	#
	def [](index)
		return @data[index]
	end

	# ==== Description
	#
	# Returns the next object in the ContentGenerator. If none is loaded, it will try to load more, until a limit is reached.
	#
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
		to_return = @data[@index]
		if(to_return!=nil)
			@index+=1
		end
		return to_return
	end

	# ==== Description
	#
	# Returns the previous object in the ContentGenerator. If the index is at 0, nil is returned
	#
	def prev
		if(@index>1)
			@index-=1
			return @data[@index-1]
		else
			return nil
		end
	end

	# ==== Description
	#
	# Resets the index of the current entry in ContentGenerator
	#
	# ==== Attributes
	#
	# * +index+ - The index that the ContentGenerator will be set to. Defaults to 0.
	#
	def reset_generator(index=0)
		@index=index
	end

	# ==== Description
	#
	# Returns the length of data already loaded into the ContentGenerator.
	#
	def length
		return @data.length
	end
end

# == Rubbit Object
#
# Object that represents an individual comment
#
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

	# ==== Description
	#
	# Submits a reply to a comment.
	#
	# ==== Attributes
	#
	# * +text+ - The body of the response
	#
	def reply(text)
		Rubbit_Poster.instance.comment(@name,text)
	end

	# ==== Description
	#
	# Deletes this comment. Only works if the comment was made by you.
	#
	def delete
		Rubbit_Poster.instance.delete(@name)
	end

	# ==== Description
	#
	# Modifies the text of this comment. Only works if the comment was made by you.
	#
	# ==== Attributes
	#
	# * +text+ - The new comment body.
	#
	def edit(text)
		Rubbit_Poster.instance.edit(@name,text)
	end

	# ==== Description
	#
	# No longer shows the comment to you on Reddit.
	#
	def hide
		Rubbit_Poster.instance.hide(@name)
	end
end

# == Rubbit Object
#
# Object representing a Reddit Post
#
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

	# ==== Description
	#
	# Makes a reply to a post
	#
	# ==== Attributes
	#
	# * +text+ - The new comment body.
	#
	def reply(text)
		return Rubbit_Poster.instance.comment(@name,text)
	end

	# ==== Description
	#
	# Retrieves the comments of a post in a list tree.
	#
	def replies
		if(@comments==nil)
			@comments = Rubbit_Object_Builder.instance.get_comments('http://www.reddit.com'+@permalink).children
		end
		return @comments
	end

	# ==== Description
	#
	# Deletes this post. Only works if you made the post.
	#
	def delete
		Rubbit_Poster.instance.delete(@name)
	end

	# ==== Description
	#
	# Modifies the text of this post. Only works if the post was made by you and is a self post.
	#
	# ==== Attributes
	#
	# * +text+ - The new post body.
	#
	def edit(text)
		Rubbit_Poster.instance.edit(@name,text)
	end

	# ==== Description
	#
	# Hides the post and no longer displays it when retrieving Reddit data
	#
	def hide
		Rubbit_Poster.instance.hide(@name)
	end

	# ==== Description
	#
	# Marks a post as NSFW. Only works if you made the post or are a moderator of the subreddit it is in.
	#
	def mark_nsfw
		Rubbit_Poster.instance.mark_nsfw(@name)
	end
end

# == Rubbit Object
#
# Object that represents a Personal Message
#
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

	# ==== Description
	#
	# Responds to an inbox message.
	#
	# ==== Attributes
	#
	# * +text+ - The new message body.
	#
	def reply(text)
		Rubbit_Poster.instance.comment(text,@name)
	end
end

class Listing
	@after = nil
	def initialize(json)
		if(json['kind']=='Listing' or json['kind']=='UserList')
			@after = nil
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