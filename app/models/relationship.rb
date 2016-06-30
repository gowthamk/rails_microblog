class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  # GK: used to be follower_id and followed_id.
  validates :follower, presence: true
  validates :followed, presence: true
end
