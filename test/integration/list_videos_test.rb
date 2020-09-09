require 'test_helper'

class ListVideosTest < ActionDispatch::IntegrationTest
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

  test "load existing videos" do
    get "/"
    assert_response :success
    assert_select "div.no-video-message", "There are no videos now"
  end

  test "add video and load existing videos" do
    post "/videos", params: { youtubeUrl: "https://www.youtube.com/watch?v=okvideoid_1" }
    assert_response :redirect
    assert_redirected_to "/"
    follow_redirect!
    assert_select "div.paging-info", "Displaying 1 video"
    assert_select "div.video-title", {count: 1}
  end
end
