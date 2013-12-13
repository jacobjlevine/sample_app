class Micropost < ActiveRecord::Base
  # get access to time_ago_in_words
  include ActionView::Helpers::DateHelper

  belongs_to :user
  default_scope -> { order("created_at DESC") }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  def posted_time_in_words
    "Posted #{time_ago_in_words(self.created_at)} ago."
  end
end
