require 'test_helper'
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

class AddNewVideoTest < ActionDispatch::IntegrationTest
  def setup
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&id=okvideoid_1&key=valid_key&part=snippet,statistics").
      to_return(status: 200, body: "
        {
          \"items\": [
            {
              \"snippet\": {
                \"title\": \"#{Faker::Lorem.sentence}\",
                \"description\": \"#{Faker::Lorem.paragraph}\",
                \"channelTitle\": \"#{Faker::Name.name}\"
              },
              \"statistics\": {
                \"viewCount\": \"#{Faker::Number.number(digits: 3)}\",
                \"likeCount\": \"#{Faker::Number.number(digits: 3)}\",
                \"dislikeCount\": \"#{Faker::Number.number(digits: 3)}\"
              }
            }
          ]
        }
        ", headers: {})
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&id=toolongvideoid_1&key=valid_key&part=snippet,statistics").
      to_return(status: 200, body: "
        {
          \"items\": []
        }
        ", headers: {})
    post "/users/sign_in", params: {user: { email: "test1@funnyvideos.com", password: "password"}}
    ENV["GOOGLE_API_KEY"] = "valid_key"
  end

  test "submit new video" do
    get "/videos/new"
    assert_response :success
    post "/videos", params: { youtubeUrl: "https://www.youtube.com/watch?v=okvideoid_1" }
    assert_response :redirect
    assert_redirected_to "/"
    follow_redirect!
    assert_select "p.notice", "Video successfully created"
  end

  test "submit an invalid video id" do
    get "/videos/new"
    assert_response :success
    post "/videos", params: { youtubeUrl: "https://www.youtube.com/watch?v=toolongvideoid_1" }
    assert_response :redirect
    follow_redirect!
    assert_select "p.alert", "Youtube video not found!"
  end

  test "submit an existing video" do
    get "/videos/new"
    assert_response :success
    post "/videos", params: { youtubeUrl: "https://www.youtube.com/watch?v=okvideoid_1" }
    assert_response :redirect
    follow_redirect!
    assert_select "p.notice", "Video successfully created"
    get "/videos/new"
    post "/videos", params: { youtubeUrl: "https://www.youtube.com/watch?v=okvideoid_1" }
    assert_response :redirect
    follow_redirect!
    assert_select "p.notice", "Video existed already"
  end
end
