class CreateAssignments < ActiveRecord::Migration
  def change
    create_table "assignments" do |t|
      t.column  :uopuser_id, :integer
      t.column  :url_id, :integer
      t.timestamps
    end
  end  
end