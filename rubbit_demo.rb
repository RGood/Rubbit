require 'Rubbit'

#Initialize Rubbit client
r = Rubbit.new 'Demo Program'

#Create an object that represents /r/AskReddit
AskReddit = r.get_subreddit('AskReddit')

#Create an enumurable object that represents the top 5 posts on the /r/AskReddit frontpage
hot = AskReddit.get_hot(5)

#Iterate through each post and output the title
hot.each do |post|
	puts post.title
end
