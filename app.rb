require("sinatra")
require("sinatra/reloader")
require('sinatra/activerecord')
also_reload("lib/**/*.rb")
require('./lib/emoji')
require('./lib/keyword')
require('./lib/sentence')
require('./lib/tweet')
require('./lib/translate')
require("pg")
require('easy_translate')
require('dotenv')
require('pry')
require('./lib/emoji')
require('./lib/keyword')
require('./lib/sentence')
require('./lib/add_tags')
require('./lib/music_notes')
Dotenv.load

get('/') do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  if @user_tweets.length > 10
    @user_tweets =  @user_tweets.slice(0,10)
  end
  @tweets = []
  @translated = []
  erb(:index)
end


post('/') do

end

post('/tweet') do
  tweet = params['tweet']
  putin = params['putin']
  if putin == "on"
    tweet = '@KremlinRussia_E ' + tweet
  end
  $twitter_client.update(tweet)

  redirect('/emoji')
end

post('/tweet_search') do
  tweet = params['tweet']
  putin = params['putin']
  if putin == "on"
    tweet = '@KremlinRussia_E ' + tweet
  end
  $twitter_client.update(tweet)
  redirect('/keyword_search')
end

post('/tweet_search_soviet') do
  tweet = params['tweet']
  tweet = '@KremlinRussia_E ' + tweet
  $twitter_client.update(tweet)
  redirect('/keyword_search/soviet')
end

get('/keyword_search') do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  if @user_tweets.length > 10
    @user_tweets =  @user_tweets.slice(0,10)
  end
  @tweets = []
  @translated = []
  erb(:keyword_search)
end

post('/keyword_search') do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  if @user_tweets.length > 10
    @user_tweets =  @user_tweets.slice(0,10)
  end
  search_term = params['search-term']
  @translated = []
  # language = params['language'].to_sym

  if !search_term.count("a-zA-Z0-9").zero?
    @tweets = $twitter_client.search(search_term, result_type: "recent").take(5).collect
    @tweets.each() do |tweet|

      tweet_text_with_info = {:user_name => tweet.user.name, :screen_name => tweet.user.screen_name,
      :created_at => tweet.created_at, :text => tweet.text, :emoji => tweet.text.to_array,
      :russian => (EasyTranslate.translate(tweet.text, :to => :russian).to_s),
      :spanish => (EasyTranslate.translate(tweet.text, :to => :spanish)),
      :japanese => (EasyTranslate.translate(tweet.text, :to => :japanese)), :music => tweet.text.music_encryption}
      @translated.push(tweet_text_with_info)
    end
  end
  if params['switch']
    @target_user = params['target_user']
  end
  # $twitter_client.update(user_name)
  # @tweets = $twitter_client.search(user_name, result_type: "recent").take(3).collect
  erb(:keyword_search)
end

get '/emoji' do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  if @user_tweets.length > 10
    @user_tweets =  @user_tweets.slice(0,10)
  end
  erb(:emoji)
end

post '/emoji' do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  tweet = params['sentence']
# time consuming operation

  @return = {:user_name => $twitter_client.user.name, :screen_name => $twitter_client.user.screen_name,
  :created_at => Time.now, :text => tweet, :emoji => tweet.to_array,
  :russian => (EasyTranslate.translate(tweet, :to => :russian)),
  :spanish => (EasyTranslate.translate(tweet, :to => :spanish)),
  :japanese => (EasyTranslate.translate(tweet, :to => :japanese)),
  :music => tweet.music_encryption}
 
  erb(:emoji)
end

get '/emoji_tweet' do
    @emoji_tweet = "@#{$twitter_client.mentions.first.user.user_name}"+" says "+" #{$twitter_client.mentions.first.text.to_array}"
  erb(:test)
end
get '/tweet_back' do
  @tweet_back = $twitter_client.update("@#{$twitter_client.mentions.first.user.user_name} #{$twitter_client.mentions.first.text.to_array}").text
  @you_tweeted = true
  erb(:test)
end

get '/keyword_search/soviet' do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  @tweets = []
  @translated = []
  erb :keyword_search_soviet,:layout => :layout_soviet
end

post'/keyword_search/soviet' do
  @user_tweets = $twitter_client.user_timeline('TwittamirPutin')
  search_term = params['search-term']
  @translated = []
  # language = params['language'].to_sym
  @tweets = $twitter_client.search(search_term, result_type: "recent").take(5).collect
  @tweets.each() do |tweet|

    tweet_text_with_info = {:user_name => tweet.user.name, :screen_name => tweet.user.screen_name,
    :created_at => tweet.created_at, :text => tweet.text, :emoji => tweet.text.to_array,
    :russian => (EasyTranslate.translate(tweet.text, :to => :russian).to_s),
    :spanish => (EasyTranslate.translate(tweet.text, :to => :spanish)),
    :japanese => (EasyTranslate.translate(tweet.text, :to => :japanese))}
    @translated.push(tweet_text_with_info)
  end
  if params['switch']
    @target_user = params['target_user']
  end
  # $twitter_client.update(user_name)
  # @tweets = $twitter_client.search(user_name, result_type: "recent").take(3).collect
  erb :keyword_search_soviet,:layout => :layout_soviet
end
