class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :slack_id
      t.boolean :is_active, default: true
      t.date :vacation_start_date
      t.date :vacation_end_date

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
