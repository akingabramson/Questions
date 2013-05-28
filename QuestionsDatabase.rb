require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")
    self.results_as_hash = true
    self.type_translation = true
  end

end


class User

  attr_reader :id, :fname, :lname

  def initialize(attribute_hash)
    @id = attribute_hash["id"]
    @fname = attribute_hash["fname"]
    @lname = attribute_hash[":lname"]
  end

  def self.find_by_id(u_id)
    query = <<-SQL
      SELECT *
      FROM users
      WHERE id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, u_id)
    User.new(attr_hash.first)

  end

  def self.find_by_name(fname, lname)
    query = <<-SQL
      SELECT *
      FROM users
      WHERE fname = ?
      AND lname = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, fname, lname)
    User.new(attr_hash.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end


end

class Question
  attr_reader :id, :title, :body, :author

  def initialize(attribute_hash)
    @id = attribute_hash["id"]
    @title = attribute_hash["title"]
    @body = attribute_hash["body"]
    @author = attribute_hash["author"]
  end

  def self.find_by_id(q_id)
    query = <<-SQL
      SELECT *
      FROM questions
      WHERE id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, q_id)
    Question.new(attr_hash.first)
  end

  def self.find_by_author_id(id)
    query = <<-SQL
      SELECT *
      FROM questions
      WHERE author = ?;
    SQL

    questions = []

    QuestionsDatabase.instance.execute(query, id).each do |attr_hash|
      questions << Reply.new(attr_hash)
    end

    questions
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
      WHERE id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, qf_id)
    Question_follower.new(attr_hash.first)
  end

end

class Reply
  attr_reader :id, :questioner_id, :parent_question_id, :parent_reply_id, :reply_body

  def initialize(attribute_hash)
    @id = attribute_hash[:id]
    @questioner_id = attribute_hash["questioner_id"]
    @parent_question_id = attribute_hash["parent_question_id"]
    @parent_reply_id = attribute_hash["parent_reply_id"]
    @reply_body = attribute_hash["reply_body"]
  end

  def self.find_by_id(r_id)
    query = <<-SQL
      SELECT *
      FROM replies
      WHERE id = ?;
    SQL

    attr_hash = QuestionsDatabase.instance.execute(query, r_id)
    Reply.new(attr_hash.first)
  end

  def self.find_by_user_id(u_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE replier_id = ?;
    SQL

    replies = []
    QuestionsDatabase.instance.execute(query, u_id).each do |attr_hash|
      replies << Reply.new(attr_hash)
    end

    replies
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

end

a = User.find_by_id(2)
p a.authored_replies
