RSpec.describe "Active Record Tests" do
  before(:all) do
    require_relative "./helpers/ac/ac_base_helper.rb"

    connect_ac()

    require_relative "./helpers/ac/questionnaire_page.rb"
    require_relative "./helpers/ac/question.rb"
    require_relative "./helpers/ac/free_question.rb"
    require_relative "./helpers/ac/preference.rb"
    require_relative "./helpers/ac/account.rb"
    require_relative "./helpers/ac/question_preference.rb"

    require_relative "./helpers/ac/ac_populate_helper.rb"
  end

  context 'Base tests' do
    before(:each) do
      reset_ac()

      @page_1 = create_page_1()
      @page_2 = create_page_2()
      @questions = create_questions(@page_1)
      @preference = create_preference(@page_1, @questions)

      @schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at ],
        :t => [ :title, :subtitle ],
        :foreign => {
          :questions => {
            :static => [ :position ],
            :translated => [ :content ]
          },
          :preference => {
            :s => [ :timeout ],
            :f => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          }
        }
      })
    end

    it "test ac export" do
      exporter = Rael::Exporter.new(@page_1, @schema)
      data_tree = exporter.export

      expect(2).to eq(data_tree.data[0][:foreign][:questions][1][:static][:position])
      expect("Question 1 es").to eq(data_tree.data[0][:foreign][:questions][0][:translated][:content][:es])
    end

    it "test ac import" do
      serialized_data_tree = Rael.export(@page_1, @schema)
      imported_tree = Rael.import(serialized_data_tree, @page_2)

      expect(@page_2.illustration).to eq("page1.png")
      expect(@page_2.translations[1].title).to eq("Page 1 fr")
      expect(@page_2.preference.first_question.position).to eq(1)
      expect(@page_2.preference.timeout).to eq("10m")
      expect(@page_2.preference.first_question.translations[2][:content]).to eq("Question 1 fr")
      expect(@page_2.questions.size).to eq(2)
    end
  end

  context 'Advanced tests' do
    before(:each) do
      reset_ac()

      @page_1 = create_page_1()
      @page_2 = create_page_2()
      @questions = create_questions(@page_1)
      @preference = create_preference(@page_1, @questions)
    end

    it "test partial update" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          }
        }
      })

      serialized_data_tree = Rael.export(@page_1, schema)
      imported_tree = Rael.import(serialized_data_tree, @page_2)

      expect(@page_2.illustration).to eq("page2.png")
      expect(@page_2.translations[1].subtitle).to eq("Section 2 fr [\"é\"]")
      expect(@page_2.translations[1].title).to eq("Page 1 fr")
    end

    it "test partial foreign update" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          }
        }
      })

      questions = create_questions(@page_2, :second_question => false)

      preference_2 = create_preference(@page_2, questions, :timeout => "50m")
      old_id = preference_2.id

      serialized_data_tree = Rael.export(@page_1, schema)
      imported_tree = Rael.import(serialized_data_tree, @page_2)

      expect(@page_2.questions.size).to eq(3)
      expect(@page_2.preference.id).to eq(old_id)
      expect(@page_2.preference.timeout).to eq("10m")
    end

    it "test multi destination update" do
      page_3 = create_page_3()
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          }
        }
      })

      Rael.clone(@page_1, schema, [@page_2, page_3])

      expect(page_3.preference.first_question.content).to eq("Question 1 en")
      expect(page_3.preference.id).not_to eq(@page_2.preference.id)
      expect(page_3.preference.id).not_to eq(@page_1.preference.id)
      expect(page_3.questions.count).to eq(2)
      expect(@page_2.questions.count).to eq(2)
    end

    it "test multi origin update" do
      page_3 = create_page_3()

      schema = Rael::Schema.new("question", {
        :static => [ :position ],
        :translated => [ :content ]
      })

      Rael.clone(@page_1.questions, schema, nil)

      expect(Question.count).to eq(4)
    end

    it "test ref tree resolution" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position, :type ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          },
          :free_questions => {
            :foreign => {
              :question_preference => {
                :options => { :foreign_key_name => "question_id" },

                :static => [ :tooltip ]
              }
            }
          }
        }
      })

      add_free_question(@page_1)
      Rael.clone(@page_1, schema, @page_2)

      expect(@page_2.questions[2]&.question_preference&.tooltip).to eq("free question tooltip")
    end

    it 'test avatar duplication' do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position, :type ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              },
              :account => {
                :s => [ :avatar ]
              }
            }
          }
        }
      })

      account = create_account(@preference)
      Rael.clone(@page_1, schema, @page_2)

      expect(@page_2.preference.account.avatar.path[-4..-1]).to eq(".gif")
    end

    it 'test serialize' do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position, :type ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout, :custom_options ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              }
            }
          }
        }
      })

      account = create_account(@preference)

      @preference.custom_options = { :a => 42 }.with_indifferent_access
      @preference.save

      Rael.clone(@page_1, schema, @page_2)

      expect(@page_2.preference.custom_options[:a]).to eq(42)
    end
  end

  context 'Error tests' do
    before(:each) do
      reset_ac()

      @page_1 = create_page_1()
      @page_2 = create_page_2()
      @questions = create_questions(@page_1)
      @preference = create_preference(@page_1, @questions)
      @account = create_account(@preference)
    end

    it "test missing key" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at, :missing_attr ],
        :translated => [ :title, :subtitle ],
      })

      expect { Rael.export(@page_1, schema) }.to raise_error(Rael::Error)
    end

    it "test missing translated key" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at ],
        :translated => [ :title, :subtitle, :missing_trad ],
      })
      expect { Rael.export(@page_1, schema) }.to raise_error(Rael::Error)
    end

    it "test missing foreign key" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at ],
        :translated => [ :title, :subtitle ],
        :foreign => {
          :missing_foreign => {
            :static => [ :position ],
            :translated => [ :content ]
          }
        }
      })

      expect { Rael.export(@page_1, schema) }.to raise_error(Rael::Error)
    end

    it "test revert mutations" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :position, :illustration, :created_at ],
        :translated => [ :title ],
        :foreign => {
          :questions => {
            :static => [ :position ],
            :translated => [ :content ]
          },
          :preference => {
            :static => [ :timeout ],
            :foreign => {
              :first_question => {
                :options => { :foreign_key_in_parent => true },
                :static => [ :position ],
                :translated => [ :content ]
              },
              :account => {
                :static => [ :unique_id ]
              }
            }
          }
        }
      })

      q_count = Question.count
      p_count = Preference.count
      qp_count = QuestionnairePage.count
      a_count = Account.count

      expect { Rael.clone(@page_1, schema, @page_2) }.to raise_error(Rael::Error)

      expect(@page_2.illustration).to eq("page2.png")
      expect(@page_2.translations[0].title).to eq("Page 2 en")
      expect(@page_2.translations[1].title).to eq("Page 2 fr")

      expect(Question.count).to eq(q_count)
      expect(Account.count).to eq(a_count)
      expect(Preference.count).to eq(p_count)
      expect(QuestionnairePage.count).to eq(qp_count)
    end

  end
end
