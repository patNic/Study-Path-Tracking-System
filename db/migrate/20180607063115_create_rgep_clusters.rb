class CreateRgepClusters < ActiveRecord::Migration[5.1]
  def change
    create_table :rgep_clusters do |t|
    	t.string :name
    	t.integer :units
    	t.timestamps
    end
  end
end
