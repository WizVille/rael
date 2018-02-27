RSpec.describe "Active Record Tests" do
  before(:all) do
    require_relative "./helpers/ac/ac_base_helper.rb"

    connect_ac()
    drop_ac_tables()
    create_ac_tables()

    require_relative "./helpers/ac/questionnaire_page.rb"
    require_relative "./helpers/ac/question.rb"
    require_relative "./helpers/ac/preference.rb"

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
        :translated => [ :title, :subtitle ],
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
      expect(@page_2.reload.preference.first_question.position).to eq(1)
      expect(@page_2.reload.preference.timeout).to eq("10m")
      expect(@page_2.reload.preference.first_question.translations[2][:content]).to eq("Question 1 fr")
      expect(@page_2.reload.questions.size).to eq(2)
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

      expect(@page_2.reload.questions.size).to eq(3)
      expect(@page_2.reload.preference.id).to eq(old_id)
      expect(@page_2.reload.preference.timeout).to eq("10m")
    end
  end

  context 'Error tests' do
    before(:each) do
      reset_ac()

      @page_1 = create_page_1()
      @page_2 = create_page_2()
      @questions = create_questions(@page_1)
      @preference = create_preference(@page_1, @questions)
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
  end
end
