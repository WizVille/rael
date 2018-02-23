RSpec.describe Rael do
  it "has a version number" do
    expect(Rael::VERSION).not_to be nil
  end

  it "test tuple" do
    t = get_questionnaire()

    expect(true).to eq(t.attributes.keys == [:illustration, :position])
    expect(true).to eq(t.static[:illustration] == "page1.png")
    expect(true).to eq(t.questions[1].static[:position] == 2)
    expect(true).to eq(t.preference.foreign[:first_question].translations[0].static[:content] == "Question 1 fr")
  end

  it "test export" do
    tuples = get_questionnaire()

    schema = {
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
              :options => { :model => "question" },
              :static => [ :position ],
              :translated => [ :content ]
            }
          }
        }
      }
    }

    exporter = Rael::Exporter.new(tuples, schema)
    result = exporter.export
  end
end
