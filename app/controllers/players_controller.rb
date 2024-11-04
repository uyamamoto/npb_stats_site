class PlayersController < ApplicationController
  def show
    # ユーザーの入力から全角・半角の空白を削除し、「・」も除去
    sanitized_query = params[:query].gsub(/\s+|・/, "")

    # 選手名または`kana`で部分一致検索し、idが一番小さい選手を取得
    @player = Player.where("REPLACE(REPLACE(name, '　', ''), ' ', '') LIKE ? OR REPLACE(REPLACE(kana, '　', ''), '・', '') LIKE ?", "%#{sanitized_query}%", "%#{sanitized_query}%")
                    .order(:id)
                    .first

    if @player.nil?
      flash[:alert] = "選手が見つかりませんでした"
      redirect_to root_path
    end
  end
end
