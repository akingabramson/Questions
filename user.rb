class User

  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(attribute_hash)
    @id = attribute_hash["id"]
    @fname = attribute_hash["fname"]
    @lname = attribute_hash["lname"]
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

  def followed_questions
    Question_follower.followed_question_for_user_id(@id)
  end

  def liked_questions
    Question_like.liked_questions_for_user_id(@id)
  end

  def average_karma

    query = <<-SQL
                SELECT COUNT(question_likes.liked_question_id)/COUNT(DISTINCT questions.id) AS avg
                FROM questions
                LEFT OUTER JOIN question_likes
                ON questions.id = question_likes.liked_question_id
                WHERE questions.author = ?;
              SQL

    avg = QuestionsDatabase.instance.execute(query, @id).first["avg"]

    if avg
      avg
    else
      0
    end

  end

  def save
    unless @id
      query = <<-SQL
        INSERT INTO users(fname, lname)
        VALUES (?, ?);
      SQL

      QuestionsDatabase.instance.execute(query, @fname, @lname)
      @id = QuestionsDatabase.last_insert_row_id
    else
      query = <<-SQL
        UPDATE users
        SET fname = ?,
            lname = ?
        WHERE id = ?;
      SQL

      QuestionsDatabase.instance.execute(query, @fname, @lname, @id)

    end
  end
end