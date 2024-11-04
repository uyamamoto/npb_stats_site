class CreateBattingStats < ActiveRecord::Migration[7.2]
  def change
    create_table :batting_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :year
      t.string :team
      t.integer :games
      t.integer :plate_appearances
      t.integer :at_bats
      t.integer :runs
      t.integer :hits
      t.integer :doubles
      t.integer :triples
      t.integer :home_runs
      t.integer :total_bases
      t.integer :rbi
      t.integer :stolen_bases
      t.integer :caught_stealing
      t.integer :sacrifice_bunts
      t.integer :sacrifice_flies
      t.integer :walks
      t.integer :hit_by_pitch
      t.integer :strikeouts
      t.integer :gidp # 併殺打
      t.decimal :avg
      t.decimal :slg
      t.decimal :obp
      t.decimal :ops
      t.decimal :k_percentage
      t.decimal :bb_percentage
      t.decimal :bb_k

      t.timestamps
    end
  end
end
