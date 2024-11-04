class CreatePitchingStats < ActiveRecord::Migration[7.2]
  def change
    create_table :pitching_stats do |t|
      t.references :player, null: false, foreign_key: true
      t.integer :year
      t.string :team
      t.integer :games
      t.integer :wins
      t.integer :losses
      t.integer :saves
      t.integer :holds
      t.integer :hold_points
      t.integer :complete_games
      t.integer :shutouts
      t.integer :no_walks
      t.decimal :win_percentage
      t.integer :batters_faced
      t.decimal :innings
      t.integer :hits
      t.integer :home_runs
      t.integer :walks
      t.integer :hit_by_pitch
      t.integer :strikeouts
      t.integer :wild_pitches
      t.integer :balks
      t.integer :runs
      t.integer :earned_runs
      t.decimal :era
      t.decimal :whip
      t.decimal :k_per_nine
      t.decimal :bb_per_nine
      t.decimal :k_bb

      t.timestamps
    end
  end
end
