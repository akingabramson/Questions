require 'singleton'
require 'sqlite3'
require_relative 'reply.rb'
require_relative 'user.rb'
require_relative 'question.rb'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end

end





class Question_follower
  attr_reader :follower_id, :question_id

  def initialize(attribute_hash)
    @follower_id = attribute_hash["follower_id"]
    @question_id = attribute_hash["question_id"]
  end

  def self.find_by_id(qf_id)
    query = <<-SQL
      SELECT  *
      FROM question_followers
      WHERE question_id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, qf_id)
    Question_follower.new(attr_hash.first)
  end

  def self.followers_for_question(q_id)
    query = <<-SQL
      SELECT u.id
      FROM question_followers q
      JOIN users u
      ON u.id = q.follower_id
      WHERE q.question_id = ?;
    SQL

    followers = []

    QuestionsDatabase.instance.execute(query, q_id).each do |attr_hash|
      followers << User.find_by_id(attr_hash["id"])
    end

    followers
  end

  def self.followed_question_for_user_id(u_id)
    query = <<-SQL
      SELECT q.id
      FROM questions q
      JOIN question_followers f
      ON q.id = f.question_id
      WHERE f.follower_id = ?;
    SQL

    followed_questions = []

    QuestionsDatabase.instance.execute(query, u_id).each do |attr_hash|
      followed_questions << Question.find_by_id(attr_hash["id"])
    end

    followed_questions
  end

  def self.most_followed_questions(n)
    query = <<-SQL
      SELECT question_id, COUNT(follower_id) AS f_count
      FROM question_followers
      GROUP BY question_id
      ORDER BY COUNT(follower_id) DESC limit ?;
    SQL

    most_followed = []

    QuestionsDatabase.instance.execute(query, n).each do |attr_hash|
      most_followed << Question.find_by_id(attr_hash["question_id"])
    end

    most_followed
  end



end


class Question_like
  attr_reader :id, :liker_id, :liked_question_id

  def initialize(attribute_hash)
    @id = attribute_hash["id"]
    @liker_id = attribute_hash["liker_id"]
    @liked_question_id = attribute_hash["liked_question_id"]
  end

  def find_by_id(ql_id)
    query = <<-SQL
      SELECT *
      FROM question_likes
      WHERE id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, ql_id)
    Question_like.new(attr_hash.first)
  end

  def self.likers_for_question_id(q_id)
    query = <<-SQL
      SELECT liked_question_id, liker_id
      FROM question_likes
      WHERE liked_question_id = ?;
    SQL

    likers = []

    QuestionsDatabase.instance.execute(query, q_id).each do |attr_hash|
      likers << User.find_by_id(attr_hash["liker_id"])
    end

    likers
  end

  def self.liked_questions_for_user_id(u_id)
    query = <<-SQL
      SELECT liked_question_id, liker_id
      FROM question_likes
      WHERE liker_id = ?;
    SQL

    liked_qs = []

    QuestionsDatabase.instance.execute(query, u_id).each do |attr_hash|
      liked_qs << Question.find_by_id(attr_hash["liked_question_id"])
    end

    liked_qs
  end

  def self.num_likes_for_question_id(q_id)
    query = <<-SQL
      SELECT liked_question_id, COUNT(liker_id) AS likes
      FROM question_likes
      WHERE liked_question_id = ?
      GROUP BY liked_question_id;
    SQL

    qid_and_count_hash = QuestionsDatabase.instance.execute(query, q_id).first
    qid_and_count_hash["likes"]

  end

  def self.most_liked_questions(n)
    query = <<-SQL
      SELECT liked_question_id, COUNT(*) AS l_count
      FROM question_likes
      GROUP BY liked_question_id
      ORDER BY COUNT(*) DESC LIMIT ?;
    SQL

    most_liked = []
    QuestionsDatabase.instance.execute(query, n).each do |attr_hash|
      most_liked << Question.find_by_id(attr_hash["liked_question_id"])
    end

    most_liked
  end

end

a = User.find_by_id(2)
p a.average_karma