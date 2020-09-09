require 'test_helper'
require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

class YoutubeIdParserTest < ActiveSupport::TestCase
  def setup
    @retriever = YoutubeDetailsRetriever.new
  end
  test "get_youtube_id from valid watch youtube url" do
    youtube_url = "http://www.youtube.com/watch?v=NLqAF9hrVbY"
    assert_equal @retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid watch youtube url with https protocol" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.youtube.com/watch?v=NLqAF9hrVbY"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid short youtube url" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://youtu.be/NLqAF9hrVbY"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid youtube url for iframe" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.youtube.com/embed/NLqAF9hrVbY"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid youtube url with multiple params" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.youtube.com/v/NLqAF9hrVbY?fs=1&hl=en_US"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid ytscreeningroom youtube url" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.youtube.com/ytscreeningroom?v=NLqAF9hrVbY"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from valid youtube query url contains dot" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.youtube.com/watch?v=NLqAF9hrVbY&feature=youtu.be"
    assert_equal retriever.get_youtube_id(youtube_url), "NLqAF9hrVbY"
  end
  test "get_youtube_id from invalid youtube url" do
    retriever = YoutubeDetailsRetriever.new
    youtube_url = "http://www.google.com/query?youtube.com=NLqAF9hrVbY&feature=youtu.be"
    assert_equal retriever.get_youtube_id(youtube_url), ""
  end
end
class YoutubeDetailsRetriverTest < ActiveSupport::TestCase
  def setup
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&id=stubbedYoutubeVideoId&key=valid_key&part=snippet,statistics").
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
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&id=notExistVideoId&key=valid_key&part=snippet,statistics").
      to_return(status: 200, body: "
        {
          \"items\": []
        }
        ", headers: {})
    stub_request(:get, "https://www.googleapis.com/youtube/v3/videos?fields=items/snippet/title,items/snippet/description,items/snippet/channelTitle,items/statistics/viewCount,items/statistics/likeCount,items/statistics/dislikeCount&id=stubbedYoutubeVideoId&key=invalid_key&part=snippet,statistics").
      to_return(status: 400, body: "
        {
          \"error\": {
            \"code\": 400,
            \"message\": \"API key not valid. Please pass a valid API key.\",
            \"errors\": [
              {
                \"message\": \"API key not valid. Please pass a valid API key.\",
                \"domain\": \"global\",
                \"reason\": \"badRequest\"
              }
            ],
            \"status\": \"INVALID_ARGUMENT\"
          }
        }
        ", headers: {})
    @retriever = YoutubeDetailsRetriever.new
    ENV["GOOGLE_API_KEY"] = "valid_key"
  end

  test "get_video_details from valid youtube id return a valid hash" do
    result = @retriever.get_video_details("stubbedYoutubeVideoId")
    assert_equal result.keys.include?(:title), true
    assert_equal result.keys.include?(:description), true
    assert_equal result.keys.include?(:publisher), true
  end

  test "get_video_details from not existed youtube id should raise exception" do
    assert_raise YoutubeDetailsRetriever::VideoNotFound  do
      @retriever.get_video_details("notExistVideoId")
    end
  end
  test "get_video_details by invalid key" do
    ENV["GOOGLE_API_KEY"] = "invalid_key"
    assert_raise OpenURI::HTTPError do
      result = @retriever.get_video_details("stubbedYoutubeVideoId")
    end
  ensure
    ENV["GOOGLE_API_KEY"] = "valid_key"
  end
end
