require 'Rubbit/Rubbit_Objects'
require 'Rubbit/Rubbit_Construction_Layer'
require 'io/console'

# == Rubbit Client
#
# Contains highest level Rubbit functionality
#
class Rubbit
	attr_accessor :client_name, :object_builder, :rubbit_poster, :me

	# ==== Description
	#
	# Initialize the Rubbit client with an ID that's added to the user agent
	#
	# ==== Attributes
	#
	# * +name+ - Attribute that identifies the bot using Rubbit. Is added to the user-agent.
	def initialize(name)
		@client_name = name
		@object_builder = Rubbit_Object_Builder.instance(name)
		@rubbit_poster = Rubbit_Poster.instance(name)
		@me = nil
	end

	# ==== Description
	#
	# Gets a Subreddit object, created by subreddit name
	#
	# ==== Attributes
	#
	# * +display_name+ - Display name of the subreddit a user wishes to create an object representation for
	def get_subreddit(display_name)
		return @object_builder.build_subreddit(display_name)
	end

	# ==== Description
	#
	# Gets a Redditor object, created by username
	#
	# ==== Attributes
	#
	# * +user+ - That Redditor's username
	def get_redditor(user)
		return @object_builder.build_user(user)
	end

	# ==== Description
	#
	# Gets a Subreddit object, created by subreddit name
	#
	# ==== Attributes
	#
	# * +display_name+ - Display name of the subreddit a user wishes to create an object representation for
	def set_request_period(period)
		@object_builder.set_request_period(period)
	end

	# ==== Description
	#
	# Login to Reddit and create a session.
	# User and passwd are *not* required. This function will prompt the user for missing information at runtime.
	#
	# ==== Attributes
	#
	# * +user+ - Username that you wish to log in with
	# * +passwd+ - Password required to log in with that user
	#
	def login(user=nil,passwd=nil)
		if(user==nil)
			print('Enter username: ')
			user = gets.chomp
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		elsif(passwd==nil)
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		end
		@me = @rubbit_poster.login(user,passwd)
		return @me
	end

	# ==== Description
	#
	# Clears the current session.
	#
	# ==== Attributes
	#
	# * +curpass+ - Password required to log in with that user
	#
	def clear_session(curpass=nil)
		if(@me==nil)
			print('Not logged in. No session to clear')
		elsif(curpass==nil)
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		end
		return @rubbit_poster.clear_sessions(curpass)
	end

	# ==== Description
	#
	# Deletes desired user. Requires auth info for that user.
	#
	# ==== Attributes
	#
	# * +user+ - Username of account you wish to delete.
	# * +passwd+ - Password required to log in with that user
	# * +message+ - Reason for deleting account.
	#
	def delete_user(user=nil,passwd=nil,message="")
		confirm = nil
		if(user==nil)
			print('Enter username: ')
			user = gets.chomp
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		elsif(passwd==nil)
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		end
		while(confirm==nil)
			print('Confirm deletion of '+user.to_s+' (y/n): ')
			answer = gets.chomp
			if(answer=='y')
				confirm = true
			elsif(answer=='n')
				confirm = false
			else
				puts("Invalid input.")
			end
		end

		return @rubbit_poster.delete_user(user,passwd,confirm,message)
	end

	def get_me()
		return @object_builder.build_user(@me.name)
	end

	def create_live(title,description='',nsfw=false)
		return @rubbit_poster.create_live(title,description,nsfw)
	end
	
	def create_subreddit(name,other_params)
		return @rubbit_poster.create_subreddit(name,other_params)
	end

	def update(curpass=nil,email=nil,newpass=nil,verify=nil,verpass=nil)
		if(@me==nil)
			print('Not logged in. Cannot update password or email')
			return false
		else
			if(curpass == nil)
				print('Enter password for '+@me.name.to_s+': ')
				curpass = STDIN.noecho(&:gets).chomp
			end
			if(email == nil)
				print('Enter new email: ')
				email = gets.chomp
			end
			if(newpass == nil)
				print('Enter new password for '+@me.name.to_s+': ')
				newpass = STDIN.noecho(&:gets).chomp
			end
			if(verify == nil)
				while(verify==nil)
					print('Are you sure? (y/n): ')
					input = gets.chomp
					if(input=='y')
						verify=true
					elsif(input=='n')
						verify= false
					end
				end
			end
			if(verpass==nil)
				print('Verify password for '+@me.name.to_s+': ')
				verpass = STDIN.noecho(&:gets).chomp
			end
			return @rubbit_poster.update(curpass,email,newpass,verify,verpass)
		end
	end

	def get_submission(link)
		return @object_builder.build_submission(link)
	end

	def get_comments(subreddit,limit)
		return @object_builder.get_comments('http://www.reddit.com/r/'+subreddit+'/comments.json',limit)
	end

	def get_inbox(limit=100)
		if(me!=nil)
			return ContentGenerator.new('http://www.reddit.com/message/inbox.json',limit)
		end
		return nil
	end

	def get_unread(limit=100)
		if(me!=nil)
			return ContentGenerator.new('http://www.reddit.com/message/unread.json',limit)
		end
		return nil
	end

	def friend(user)
		return @rubbit_poster.friend('friend',user,@me.name)
	end

	def unfriend(user)
		return @rubbut_poster.unfriend('friend',user,@me.name)
	end

	def get_sent(limit=100)
		if(me!=nil)
			return ContentGenerator.new('http://www.reddit.com/message/sent.json',limit)
		end
		return nil
	end

	def submit(sr,title,url=nil,text=nil,kind='self',resubmit=false,save=false,sendreplies=true)
		if(@me!=nil)
			return @rubbit_poster.submit(sr,title,url,text,kind,resubmit,save,sendreplies)
		end
		return nil
	end

	def comment(text,parent)
		if(@me!=nil)
			return @rubbut_poster.comment(text,parent)
		end
		return nil
	end
end