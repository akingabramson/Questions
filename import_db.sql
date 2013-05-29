CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	fname VARCHAR(255) NOT NULL,
	lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
	id INTEGER PRIMARY KEY,
	title VARCHAR(255) NOT NULL,
	body TEXT NOT NULL,
	author INTEGER NOT NULL,

	FOREIGN KEY(author) REFERENCES users(id)
);

CREATE TABLE question_followers (
	follower_id INTEGER NOT NULL,
	question_id INTEGER NOT NULL,

	FOREIGN KEY(follower_id) REFERENCES users(id),
	FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
	id INTEGER PRIMARY KEY,
	replier_id INTEGER NOT NULL,
	parent_question_id INTEGER NOT NULL,
	parent_reply_id INTEGER,
	reply_body TEXT NOT NULL,

	FOREIGN KEY(parent_question_id) REFERENCES questions(id),
	FOREIGN KEY(parent_reply_id) REFERENCES replies(id),
	FOREIGN KEY(replier_id) REFERENCES users(id)

);

CREATE TABLE question_likes (
	id INTEGER PRIMARY KEY,
	liker_id INTEGER NOT NULL,
	liked_question_id INTEGER NOT NULL,

	FOREIGN KEY(liker_id) REFERENCES users(id),
	FOREIGN KEY(liked_question_id) REFERENCES questions(id)

);

INSERT INTO users(fname, lname)
VALUES ('Aaron', 'Rama'),
('Asher', 'King Abramson'),
('George', 'Haws');

INSERT INTO questions(title, body, author)
VALUES ('Why don"t birds get electrocuted on telephone wires?',
'self explanatory', 2),
('Who am I?', 'Aaron Rama', 2),
('What is this?', 'Aaron Rama', 2),
('Where is this?', 'here', 3);

INSERT INTO question_followers(follower_id, question_id)
VALUES (1, 2),
(2, 1),
(3, 1);


INSERT INTO replies (replier_id, parent_question_id, parent_reply_id, reply_body)
VALUES (2, 1, NULL, 'I respectfully disagree'),
(3, 1, 1, 'I respectfully agree');

INSERT INTO question_likes(liker_id, liked_question_id)
VALUES (3, 1),
(2, 1),
(3, 2),
(1, 2),
(1, 1),
(1, 4);



