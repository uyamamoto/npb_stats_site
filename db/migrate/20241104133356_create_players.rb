class CreatePlayers < ActiveRecord::Migration[7.2]
  def change
    create_table :players do |t|
      t.string :url
      t.string :name
      t.string :team
      t.string :number # 育成選手は018のような背番号になるので、stringとして保存
      t.string :kana
      t.string :photo_url
      t.string :position
      t.string :throws_bats
      t.string :height_weight
      t.string :birthdate
      t.string :career
      t.string :draft

      t.timestamps
    end
  end
end
