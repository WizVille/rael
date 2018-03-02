def create_page_1
  q_page = QuestionnairePage.new

  q_page.illustration = "page1.png"
  q_page.created_at = Time.now
  q_page.position = 1
  q_page.save

  q_page.attributes = { :title => "Page 1 fr", :subtitle => "Section 1 fr [\"é\"]", :locale => :fr }
  q_page.attributes = { :title => "Page 1 en", :subtitle => "Section 1 en [\"é\"]", :locale => :en }
  q_page.save

  q_page
end

def create_page_2
  q_page = QuestionnairePage.new

  q_page.illustration = "page2.png"
  q_page.created_at = Time.now
  q_page.position = 2
  q_page.save

  q_page.attributes = { :title => "Page 2 fr", :subtitle => "Section 2 fr [\"é\"]", :locale => :fr }
  q_page.attributes = { :title => "Page 2 en", :subtitle => "Section 2 en [\"é\"]", :locale => :en }
  q_page.save

  q_page
end

def create_page_3
  q_page = QuestionnairePage.new

  q_page.illustration = "page3.png"
  q_page.created_at = Time.now
  q_page.position = 2
  q_page.save

  q_page.attributes = { :title => "Page 3 fr", :subtitle => "Section 3 fr [\"é\"]", :locale => :fr }
  q_page.attributes = { :title => "Page 3 en", :subtitle => "Section 3 en [\"é\"]", :locale => :en }
  q_page.save

  q_page
end

def create_account(preference, unique_id: 1, name: "account 1")
  a = Account.new

  a.unique_id = unique_id
  a.name = name
  a.preference_id = preference.id
  a.save

  a
end

def create_questions(q_page, second_question: true)
  questions = []

  question_1 = Question.new

  question_1.position = 1
  question_1.questionnaire_page_id = q_page.id
  question_1.save

  question_1.attributes = { :content => "Question 1 en", :locale => :en }
  question_1.save

  question_1.attributes = { :content => "Question 1 es", :locale => :es }
  question_1.save

  question_1.attributes = { :content => "Question 1 fr", :locale => :fr }
  question_1.save

  questions << question_1

  if second_question
    question_2 = Question.new

    question_2.position = 2
    question_2.questionnaire_page_id = q_page.id
    question_2.save

    question_2.attributes = { :content => "Question 2 en", :locale => :en }
    question_2.save

    question_2.attributes = { :content => "Question 2 fr", :locale => :fr }
    question_2.save

    questions << question_2
  end

  questions
end

def add_free_question(q_page)
  question = FreeQuestion.new

  question.position = 42
  question.questionnaire_page_id = q_page.id
  question.save

  question.attributes = { :content => "Question free en", :locale => :en }
  question.save

  qp = QuestionPreference.new
  qp.question_id = question.id
  qp.tooltip = "free question tooltip"
  qp.save

  question
end

def create_preference(q_page, questions, timeout: "10m")
  preference = Preference.new

  preference.timeout = timeout
  preference.questionnaire_page_id = q_page.id
  preference.first_question_id = questions[0].id
  preference.save

  preference
end
