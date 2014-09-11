require 'Rubbit'

r = Rubbit.new 'Demo Program'

AskReddit = r.get_subreddit('AskReddit')

hot = AskReddit.get_hot(5)

hot.each do |post|
	puts post.title
end