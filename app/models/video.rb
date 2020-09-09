class Video < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id
  validates :video_id, length: {is: 11}, allow_blank: false
end
