require 'Rubbit/Rubbit_Objects'
require 'Rubbit/Rubbit_Construction_Layer'
require 'io/console'

class Rubbit
	attr_accessor :client_name, :object_builder, :rubbit_poster, :me

	def initialize(name)
		@client_name = name
		@object_builder = Rubbit_Object_Builder.instance(name)
		@rubbit_poster = Rubbit_Poster.instance(name)
		@me = nil
	end

	def get_subreddit(display_name)
		return @object_builder.build_subreddit(display_name)
	end

	def get_redditor(user)
		return @object_builder.build_user(user)
	end

	def set_request_period(period)
		@object_builder.set_request_period(period)
	end

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

	def clear_session(curpass=nil,uh=nil)
		if(@me==nil)
			print('Not logged in. No session to clear')
		elsif(curpass==nil)
			print('Enter password for '+user.to_s+': ')
			passwd = STDIN.noecho(&:gets).chomp
		end
		return @rubbit_poster.clear_sessions(curpass,uh)
	end

	def delete_user(user=nil,passwd=nil,message="",uh=nil)
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

		return @rubbit_poster.delete_user(user,passwd,confirm,message,@me.uh)
	end

	def get_me()
		return @object_builder.build_user(@me.name)
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