RSpec.describe "Tuples Tests" do
  it "test tuple" do
    tuples = get_questionnaire()

    expect(true).to eq(tuples.attributes.keys == [:illustration, :created_at, :position])
    expect(true).to eq(tuples.static[:illustration] == "page1.png")
    expect(true).to eq(tuples.questions[1].static[:position] == 2)
    expect(true).to eq(tuples.preference.foreign[:first_question].translations[0].static[:content] == "Question 1 fr")
  end

  it "test t export" do
    tuples = get_questionnaire()

    schema = Rael::Schema.new("tuple", {
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
              :options => { :model_name => "question", :foreign_key_in_parent => true },
              :static => [ :position ],
              :translated => [ :content ]
            }
          }
        }
      }
    })

    exporter = Rael::Exporter.new(tuples, schema)
    data_tree = exporter.export

    expect(true).to eq(data_tree.data[0][:foreign][:questions][1][:static][:position] == 2)
    expect(true).to eq(data_tree.data[0][:foreign][:questions][0][:translated][:content][:es] == "Question 1 es")
    expect(true).to eq(data_tree.data[0][:foreign][:preference][:foreign][:first_question][:ref] == :"tuples <__1>")
  end

  it "test t operations" do
    tuples = get_questionnaire()

    schema = Rael::Schema.new("tuple", {
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
              :options => { :model_name => "question", :foreign_key_in_parent => true },
              :static => [ :position ],
              :translated => [ :content ]
            }
          }
        }
      }
    })

    exporter = Rael::Exporter.new(tuples, schema)
    data_tree = exporter.export

    operations = Rael::Importer.new(data_tree).get_operations(partial_origin)

    expect(true).to eq(operations[0].type == :update)
    expect(true).to eq(operations[1].type == :update)
    expect(true).to eq(operations[2].type == :create)
    expect(true).to eq(operations[3].type == :update)
    expect(true).to eq(operations[4].type == :update)
    expect(true).to eq(operations[4].model_name&.to_sym == :"question")
    expect(true).to eq(operations[4].parent_model_name&.to_sym == :"preference")
  end
end
