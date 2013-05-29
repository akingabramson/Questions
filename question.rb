class Question
  attr_accessor :title, :body, :author
  attr_reader :id

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

  def author
    User.find_by_id(@author)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    Question_follower.followers_for_question(@id)
  end

  def self.most_followed(n)
    Question_follower.most_followed_questions(n)
  end

  def self.most_liked(n)
    Question_like.most_liked_questions(n)
  end

  def likers
    Question_like.likers_for_question_id(@id)
  end

  def num_likes
    Question_like.num_likes_for_question_id(@id)
  end

  def save
    unless @id
      query = <<-SQL
        INSERT INTO questions(title, body, author)
        VALUES (?, ?, ?);
      SQL

      QuestionsDatabase.instance.execute(query, @title, @body, @author)
      @id = QuestionsDatabase.last_insert_row_id
    else
      query = <<-SQL
        UPDATE questions
        SET title = ?,
            body = ?,
            author = ?
        WHERE id = ?;
      SQL

      QuestionsDatabase.instance.execute(query, @title, @body, @author, @id)

    end
  end

end