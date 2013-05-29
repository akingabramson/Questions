class Reply
  attr_reader :id, :replier_id, :parent_question_id, :parent_reply_id, :reply_body

  def initialize(attribute_hash)
    @id = attribute_hash["id"]
    @replier_id = attribute_hash["replier_id"]
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

  def self.find_by_question_id(q_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE parent_question_id = ?;
    SQL

    replies = []
    QuestionsDatabase.instance.execute(query, q_id).each do |attr_hash|
      replies << Reply.new(attr_hash)
    end

    replies
  end

  def author
    User.find_by_id(@replier_id)
  end

  def question
    Question.find_by_id(@parent_question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    query = <<-SQL
      SELECT *
      FROM replies r1
      JOIN replies r2
      ON r2.parent_reply_id = r1.id
      WHERE r1.id = ?;
    SQL

    child_replies = []
    QuestionsDatabase.instance.execute(query, @id).each do |attr_hash|
      child_replies << Reply.new(attr_hash)
    end
    child_replies
  end

end