require 'logger'

def connect_ac
  ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:"
  )

  ActiveRecord::Schema.define do
      create_table :questionnaire_pages do |table|
          table.column :illustration, :string
          table.column :created_at, :datetime
          table.column :position, :integer
      end

      create_table :questionnaire_page_translations do |table|
          table.column :locale, :string
          table.column :title, :string
          table.column :subtitle, :string
          table.column :questionnaire_page_id, :integer
      end

      create_table :questions do |table|
          table.column :questionnaire_page_id, :integer
          table.column :position, :integer
          table.column :type, :string
      end

      create_table :question_translations do |table|
          table.column :locale, :string
          table.column :content, :string
          table.column :question_id, :integer
      end

      create_table :preferences do |table|
          table.column :timeout, :string
          table.column :first_question_id, :integer
          table.column :questionnaire_page_id, :integer
      end

      create_table :accounts do |table|
          table.column :unique_id, :string
          table.column :name, :string
          table.column :preference_id, :integer
          table.column :avatar, :string
      end

      create_table :question_preferences do |table|
          table.column :tooltip, :string
          table.column :question_id, :integer
      end
  end
end

def reset_ac
  QuestionnairePage.destroy_all
  Question.destroy_all
  Preference.destroy_all
  Account.destroy_all
end
