class CreateUopusers < ActiveRecord::Migration
  def change
    create_table "uopusers" do |t|
      t.string   "name"
      t.string   "email"
      t.string   "uid"
      t.timestamps
    end
  end  
end
