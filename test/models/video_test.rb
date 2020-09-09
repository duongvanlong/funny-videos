require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  test "validate video_id not nil" do
    user = users(:one)
    video = Video.new(video_id: nil, user_id: user.id)
    refute video.valid?
    assert_not_nil video.errors[:video_id]
  end
  test "validate user_id not nil" do
    video = Video.new(video_id: SecureRandom.hex[0...11])
    refute video.valid?
    assert_not_nil video.errors[:video_id]
  end

  test "validate video_id not enough 11 characters" do
    user = users(:one)
    video = Video.new(video_id: "Test", user_id: user.id)
    refute video.valid?
    assert_not_nil video.errors[:video_id]
  end

  test "validate video_id has more than 11 characters" do
    user = users(:one)
    video = Video.new(video_id: SecureRandom.hex[0...12], user_id: user.id)
    refute video.valid?
    assert_not_nil video.errors[:video_id]
  end

  test "validate video_id has enough 11 characters" do
   user = users(:one)
    video = Video.new(video_id: SecureRandom.hex[0...11], user_id: user.id)
    assert_equal video.valid?, true
    assert_equal video.errors[:video_id], []
  end

end
