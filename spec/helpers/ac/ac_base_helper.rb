def connect_ac
  ActiveRecord::Base.establish_connection(
    adapter:  'mysql2',
    host:     'localhost',
    database: 'rael_test',
    username: 'root',
    password: ''
  )
end

def reset_ac
  QuestionnairePage.destroy_all
  Question.destroy_all
  Preference.destroy_all
  Account.destroy_all
end

def drop_ac_tables
  ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS accounts, questionnaire_pages, questionnaire_page_translations, questions, question_translations, preferences;")
end

def create_ac_tables
  create_questionnaire_pages = <<~eos
    CREATE TABLE IF NOT EXISTS questionnaire_pages (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      illustration VARCHAR(255),
      created_at DATETIME,
      position INT
    );
  eos

  create_questionnaire_page_translations = <<~eos
    CREATE TABLE IF NOT EXISTS questionnaire_page_translations (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      locale VARCHAR(255),
      title VARCHAR(255),
      subtitle VARCHAR(255),
      questionnaire_page_id INT
    );
  eos

  create_questions = <<~eos
    CREATE TABLE IF NOT EXISTS questions (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    questionnaire_page_id INT,
    position INT
    );
  eos

  create_question_translations = <<~eos
    CREATE TABLE IF NOT EXISTS question_translations (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      locale VARCHAR(255),
      content VARCHAR(255),
      question_id INT
    );
  eos

  create_preferences = <<~eos
    CREATE TABLE IF NOT EXISTS preferences (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    timeout VARCHAR(255),
    first_question_id INT,
    questionnaire_page_id INT
    );
  eos

  create_accounts = <<~eos
    CREATE TABLE IF NOT EXISTS accounts (
      id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
      unique_id INT,
      name VARCHAR(255),
      preference_id INT
    );
  eos


  ActiveRecord::Base.connection.execute(create_questionnaire_pages)
  ActiveRecord::Base.connection.execute(create_questions)
  ActiveRecord::Base.connection.execute(create_preferences)
  ActiveRecord::Base.connection.execute(create_accounts)

  ActiveRecord::Base.connection.execute(create_questionnaire_page_translations)
  ActiveRecord::Base.connection.execute(create_question_translations)
end
