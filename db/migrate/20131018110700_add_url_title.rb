class AddUrlTitle < ActiveRecord::Migration
  def change
    change_table :urls do |t|
      t.string :title, :limit => 255
    end
  end
end