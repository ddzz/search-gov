class Affiliate < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  validates_length_of :name, :within=> (3..33)
  validates_format_of :name, :with=> /^[\w.-]+$/i
  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :users
  belongs_to :affiliate_template
  has_many :boosted_contents, :dependent => :destroy
  has_many :sayt_suggestions, :dependent => :destroy
  has_many :calais_related_searches, :dependent => :destroy
  after_destroy :remove_boosted_contents_from_index
  before_save :set_default_affiliate_template
  after_create :add_owner_as_user

  USAGOV_AFFILIATE_NAME = 'usasearch.gov'
  VALID_RELATED_TOPICS_SETTINGS = %w{affiliate_enabled global_enabled disabled}

  def is_owner?(user)
    self.owner == user ? true : false
  end
  
  def is_affiliate_sayt_enabled?
    self.is_sayt_enabled && self.is_affiliate_suggestions_enabled
  end
  
  def is_global_sayt_enabled?
    self.is_sayt_enabled && !self.is_affiliate_suggestions_enabled
  end
  
  def is_sayt_disabled?
    !self.is_sayt_enabled && !self.is_affiliate_suggestions_enabled
  end
  
  def is_affiliate_related_topics_enabled?
    (self.related_topics_setting != 'global_enabled' && self.related_topics_setting != 'disabled') || self.related_topics_setting.nil?
  end
  
  def is_global_related_topics_enabled?
    self.related_topics_setting == 'global_enabled'
  end
  
  def is_related_topics_disabled?
    self.related_topics_setting == 'disabled'
  end

  def template
    affiliate_template.presence || AffiliateTemplate.default_template
  end
  
  private

  def remove_boosted_contents_from_index
    boosted_contents.each { |bs| bs.remove_from_index }
  end
  
  def add_owner_as_user
    self.users << self.owner if self.owner
  end

  def set_default_affiliate_template
    self.staged_affiliate_template_id = AffiliateTemplate.default_id if staged_affiliate_template_id.blank?
    self.affiliate_template_id = AffiliateTemplate.default_id if affiliate_template_id.blank?
  end
end
