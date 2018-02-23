RSpec.describe Rael do
  it "has a version number" do
    expect(Rael::VERSION).not_to be nil
  end

  it "test tuple" do
    a = get_questionnaire()

    expect(true).to eq(a.static[:illustration] == "page1.png")
    expect(true).to eq(a.questions[1].static[:position] == 2)
    expect(true).to eq(a.preference.foreign[:first_question].translations[0].static[:content] == "Question 1 fr")
  end

  it "text export" do
    
  end
end
