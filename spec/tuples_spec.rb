RSpec.describe "Tuples Tests" do
  context "Tuples" do
    before(:each) do
      @tuples = get_questionnaire()
    end

    it "test tuple" do
      expect(@tuples.attributes.keys).to eq([:illustration, :created_at, :position])
      expect(@tuples.static[:illustration]).to eq("page1.png")
      expect(@tuples.questions[1].static[:position]).to eq(2)
      expect(@tuples.preference.foreign[:first_question].translations[0].static[:content]).to eq("Question 1 fr")
    end

    it "test tuple export" do
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

      exporter = Rael::Exporter.new(@tuples, schema)
      data_tree = exporter.export

      expect(data_tree.data[0][:foreign][:questions][1][:static][:position]).to eq(2)
      expect(data_tree.data[0][:foreign][:questions][0][:translated][:content][:es]).to eq("Question 1 es")
      expect(data_tree.data[0][:foreign][:preference][:foreign][:first_question][:ref]).to eq(:"tuples <__1>")
    end

    it "test tuple operations" do
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

      exporter = Rael::Exporter.new(@tuples, schema)
      data_tree = exporter.export

      operations = Rael::Importer.new(data_tree).get_operations(partial_origin)

      expect(operations[0].type).to eq(:update)
      expect(operations[1].type).to eq(:update)
      expect(operations[2].type).to eq(:create)
      expect(operations[3].type ).to eq(:update)
      expect(operations[4].type).to eq(:update)
      expect(operations[4].model_name&.to_sym).to eq(:"question")
      expect(operations[4].parent_model_name&.to_sym).to eq(:"preference")
    end

    it "Missing key" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at, :missing_attr ],
        :translated => [ :title, :subtitle ],
      })

      expect { Rael.export(@tuples, schema) }.to raise_error(Rael::Error)
    end

    it "Missing translated key" do
      schema = Rael::Schema.new("questionnaire_page", {
        :static => [ :illustration, :position, :created_at ],
        :translated => [ :title, :subtitle, :missing_trad ],
      })
      expect { Rael.export(@tuples, schema) }.to raise_error(Rael::Error)
    end

    it "Missing foreign key" do
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

      expect { Rael.export(@tuples, schema) }.to raise_error(Rael::Error)
    end
  end
end
