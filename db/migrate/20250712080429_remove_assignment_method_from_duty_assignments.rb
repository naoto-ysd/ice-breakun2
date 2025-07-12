class RemoveAssignmentMethodFromDutyAssignments < ActiveRecord::Migration[8.0]
  def change
    remove_column :duty_assignments, :assignment_method, :string
  end
end
