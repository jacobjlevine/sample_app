class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, class_name: "Relationship",
           foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :reverse_relationships

  before_save { email.downcase! }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@([a-z\d\-]+\.)+[a-z]+\z/i
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }
  validates :password, length: { minimum: 6 }

  has_secure_password

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def feed
    user_ids_for_feed = "SELECT id FROM relationships
                        WHERE follower_id = :user_id
                        UNION ALL
                        SELECT :user_id"
    Micropost.where("user_id IN (#{user_ids_for_feed})", user_id: id)

  end

  # used mostly for testing; generally would use the
  # follow! method to create a new relationship
  def build_relationship(followed)
    self.relationships.build(followed: followed)
  end

  def follow!(followed)
    self.relationships.create!(followed: followed)
    end

  def unfollow!(followed)
    self.relationships.find_by(followed: followed).destroy!
  end

  def following?(user)
    user.in? followed_users
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end

end
