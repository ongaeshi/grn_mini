require 'minitest_helper'

class TestMicroBlog < MiniTest::Test
  def test_micro_blog
    GrnMini::tmpdb do
      engine = MicroBlog.new

      # Add user
      engine.add_user("aaa", "Mr. A", "Hello.")
      engine.add_user("bbb", "Mr. B", "Good Afternoon.")
      engine.add_user("ccc", "Mr. C", "Hi.")

      # Follow
      engine.follow("bbb", "aaa")
      engine.follow("ccc", "aaa")
      engine.follow("ccc", "bbb")

      users = engine.users
      assert_equal 0, users["aaa"].follower.size
      assert_equal 1, users["bbb"].follower.size
      assert_equal 2, users["ccc"].follower.size

      # Followee
      assert_equal 2, engine.followee("aaa").size
      assert_equal 1, engine.followee("bbb").size
      assert_equal 0, engine.followee("ccc").size
    end
  end

  class MicroBlog
    attr_reader :users
    attr_reader :comments
    attr_reader :hash_tags
    
    def initialize
      @users = GrnMini::Hash.new("Users")
      @comments = GrnMini::Hash.new("Comments")
      @hash_tags = GrnMini::Hash.new("HashTags")

      @users.setup_columns(name: "User Name",
                           follower: [users],
                           favorites: [comments],
                           description: ""
                           )

      @comments.setup_columns(comment: "",
                              last_modified: Time.new,
                              replied_to: [comments],
                              replied_users: [users],
                              hash_tags: [hash_tags],
                              posted_by: users
                              )
    end

    def add_user(id, name, description)
      @users[id] = {name: name, description: description }
    end

    def follow(user_id, follow_id)
      @users[user_id].follower += [@users[follow_id]]
    end

    def followee(user_id)
      @users.select("follower:#{user_id}")
    end
  end
end
