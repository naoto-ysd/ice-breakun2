class CreateDutyAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :duty_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.date :assignment_date
      t.string :assignment_method
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
