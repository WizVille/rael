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

    expect(true).to eq(data_tree.data[0][:foreign][:questions][1][:static][:position] == 2)
    expect(true).to eq(data_tree.data[0][:foreign][:questions][0][:translated][:content][:es] == "Question 1 es")
  end

  it "test ac import" do
    exporter = Rael::Exporter.new(@page_1, @schema)
    data_tree = exporter.export
    serialized_data_tree = data_tree.serialize()

    Rael::Importer.new(serialized_data_tree).import(@page_2)

    expect(true).to eq(@page_2.reload.preference.first_question.position == 1)
    expect(true).to eq(@page_2.reload.preference.timeout == "10m")
    expect(true).to eq(@page_2.reload.preference.first_question.translations[2][:content] == "Question 1 fr")
    expect(true).to eq(@page_2.reload.questions.size == 2)
  end
end
