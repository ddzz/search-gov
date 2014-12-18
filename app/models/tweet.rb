class Tweet < ActiveRecord::Base
  before_save :sanitize_tweet_text
  belongs_to :twitter_profile, :primary_key => :twitter_id
  validates_presence_of :tweet_id, :tweet_text, :published_at, :twitter_profile_id
  validates_uniqueness_of :tweet_id
  serialize :urls, Array

  def sanitize_tweet_text
    self.tweet_text = Sanitize.clean(tweet_text).squish if tweet_text
  end

  def url_to_tweet
    "https://twitter.com/#{twitter_profile.screen_name}/status/#{tweet_id}"
  end

  def language
    twitter_profile.affiliates.first.locale
  rescue
    Rails.logger.warn "Found Tweet with no affiliate, so defaulting to English locale"
    'en'
  end

  def as_json
    { text: tweet_text,
      url: url_to_tweet,
      name: twitter_profile.name,
      screen_name: twitter_profile.screen_name,
      profile_image_url: twitter_profile.profile_image_url,
      created_at: published_at }
  end
end
