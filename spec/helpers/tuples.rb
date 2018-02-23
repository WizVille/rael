def get_questionnaire
  tuples = Rael::Tuple.new(
  	:static => { :illustration => "page1.png", :position => 1 },
  	:translated => {
  		:title => { :fr => "Page 1 fr", :en => "Page 1 en" },
  		:subtitle => { :fr => "Section 1 fr", :en => "Section 1 en" },
  	},
  	:foreign => {
  		:questions => [
  			Rael::Tuple.new(
          :id => "__1",
          :static => { :position => 1 },
          :translated => {
            :content => { :fr => "Question 1 fr", :en => "Question 1 en", :es => "Question 1 es" }
          },
        ),
        Rael::Tuple.new(
          :static => { :position => 2 },
          :translated => {
            :content => { :fr => "Question 2 fr", :en => "Question 2 en" }
          },
        )
      ],
      :preference => Rael::Tuple.new(
        :static => { :timeout => "10m" },
        :foreign => {
          :first_question => "__1"
        }
      )
  	}
  )

  Rael::Tuple.resolve_foreign_keys
  Rael::Tuple.reset

  return tuples
end
