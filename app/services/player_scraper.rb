class PlayerScraper
  require "nokogiri"
  require "open-uri"

  # https://npb.jp/bis/teams/rst_#{チーム名}.htmlから各チームの全選手のurlを取得できる
  BASE_URL = "https://npb.jp/bis/teams/"
  TEAM_NAMES = [ "t", "c", "db", "g", "s", "d", "b", "m", "h", "e", "l", "f" ]

  # * 全選手の成績ページのURLを取得するメソッド
  def self.fetch_player_urls
    player_urls = [] # 最終的に取得したい選手個別のURL
    TEAM_NAMES.each do |team_name|
      team_url = "#{BASE_URL}rst_#{team_name}.html"
      doc = Nokogiri::HTML(URI.open(team_url))

      # class="rosterPlayer"の行をすべて取得
      doc.css(".rosterPlayer").each do |player_row|
        # class="rosterRegister"の中のaタグを探す
        player_link = player_row.at_css(".rosterRegister a")
        # aタグが存在するかチェック
        if player_link
          link = player_link["href"]
          full_link = "https://npb.jp#{link}"
          player_urls << full_link
        end

        puts player_link

        # ! 各リクエストの間に待機時間を設定
        sleep(1)
      end
    end

    # Playerテーブルに選手のURLを保存
    player_urls.each do |url|
      Player.find_or_create_by(url: url)
    end
  end

  # * 各選手のページからデータを取得するメソッド
  def self.scrape_player_data
    # ! 扱いたい年度を指定
    target_year = 2024

    # URLがすでにデータベースに格納されているPlayerエントリーを取得
    Player.where.not(url: nil).find_each do |player|
      begin
        doc = Nokogiri::HTML(URI.open(player.url))

        # * 全選手共通のデータの取得
        name = doc.at_css("li#pc_v_name").text.strip
        team = doc.at_css("#pc_v_team").text.strip
        number = doc.at_css("#pc_v_no").text.strip
        kana = doc.at_css("#pc_v_kana").text.strip
        photo_url = doc.at_css("#pc_v_photo img")["src"]
        # bioセクションからの情報を取得
        bio_section = doc.at_css("#pc_bio")
        position = bio_section.at_css("tr:nth-of-type(1) td").text.strip
        throws_bats = bio_section.at_css("tr:nth-of-type(2) td").text.strip
        height_weight = bio_section.at_css("tr:nth-of-type(3) td").text.strip
        birthdate = bio_section.at_css("tr:nth-of-type(4) td").text.strip
        career = bio_section.at_css("tr:nth-of-type(5) td").text.strip
        draft = bio_section.at_css("tr:nth-of-type(6) td").text.strip

        # データベースを更新
        player.update(
          name: name,
          team: team,
          number: number,
          kana: kana,
          photo_url: photo_url,
          position: position,
          throws_bats: throws_bats,
          height_weight: height_weight,
          birthdate: birthdate,
          career: career,
          draft: draft
        )

        # * 投手の場合: 投手成績をスクレイピング
        if position == "投手"
          doc.css(".registerStats").each do |stats_row|
            # 取得したい年度を指定し、それ以外は扱わない
            year = stats_row.at_css(".year").text.strip.to_i
            next unless year == target_year

            # 各投手成績を取得
            team = stats_row.at_css("td:nth-of-type(2)").text.strip
            games = stats_row.at_css("td:nth-of-type(3)").text.strip.to_i
            wins = stats_row.at_css("td:nth-of-type(4)").text.strip.to_i
            losses = stats_row.at_css("td:nth-of-type(5)").text.strip.to_i
            saves = stats_row.at_css("td:nth-of-type(6)").text.strip.to_i
            holds = stats_row.at_css("td:nth-of-type(7)").text.strip.to_i
            hold_points = stats_row.at_css("td:nth-of-type(8)").text.strip.to_i
            complete_games = stats_row.at_css("td:nth-of-type(9)").text.strip.to_i
            shutouts = stats_row.at_css("td:nth-of-type(10)").text.strip.to_i
            no_walks = stats_row.at_css("td:nth-of-type(11)").text.strip.to_i
            win_percentage = stats_row.at_css("td:nth-of-type(12)").text.strip.to_f
            batters_faced = stats_row.at_css("td:nth-of-type(13)").text.strip.to_i
            innings = extract_innings(stats_row.at_css("td:nth-of-type(14)"))
            hits = stats_row.at_css("td:nth-of-type(15)").text.strip.to_i
            home_runs = stats_row.at_css("td:nth-of-type(16)").text.strip.to_i
            walks = stats_row.at_css("td:nth-of-type(17)").text.strip.to_i
            hit_by_pitch = stats_row.at_css("td:nth-of-type(18)").text.strip.to_i
            strikeouts = stats_row.at_css("td:nth-of-type(19)").text.strip.to_i
            wild_pitches = stats_row.at_css("td:nth-of-type(20)").text.strip.to_i
            balks = stats_row.at_css("td:nth-of-type(21)").text.strip.to_i
            runs = stats_row.at_css("td:nth-of-type(22)").text.strip.to_i
            earned_runs = stats_row.at_css("td:nth-of-type(23)").text.strip.to_i
            era = stats_row.at_css("td:nth-of-type(24)").text.strip.to_f
            whip = cal_whip(walks, hits, innings)
            k_per_nine = cal_k_per_nine(strikeouts, innings)
            bb_per_nine = cal_bb_per_nine(walks, innings)
            k_bb = cal_k_bb(strikeouts, walks)


            # PitchingStatが存在するか確認し、存在しない場合は新規作成
            if player.pitching_stat.present?
              player.pitching_stat.update(
                year: year,
                team: team,
                games: games,
                wins: wins,
                losses: losses,
                saves: saves,
                holds: holds,
                hold_points: hold_points,
                complete_games: complete_games,
                shutouts: shutouts,
                no_walks: no_walks,
                win_percentage: win_percentage,
                batters_faced: batters_faced,
                innings: innings,
                hits: hits,
                home_runs: home_runs,
                walks: walks,
                hit_by_pitch: hit_by_pitch,
                strikeouts: strikeouts,
                wild_pitches: wild_pitches,
                balks: balks,
                runs: runs,
                earned_runs: earned_runs,
                era: era,
                whip: whip,
                k_per_nine: k_per_nine,
                bb_per_nine: bb_per_nine,
                k_bb: k_bb
              )
            else
              player.create_pitching_stat(
                year: year,
                team: team,
                games: games,
                wins: wins,
                losses: losses,
                saves: saves,
                holds: holds,
                hold_points: hold_points,
                complete_games: complete_games,
                shutouts: shutouts,
                no_walks: no_walks,
                win_percentage: win_percentage,
                batters_faced: batters_faced,
                innings: innings,
                hits: hits,
                home_runs: home_runs,
                walks: walks,
                hit_by_pitch: hit_by_pitch,
                strikeouts: strikeouts,
                wild_pitches: wild_pitches,
                balks: balks,
                runs: runs,
                earned_runs: earned_runs,
                era: era,
                whip: whip,
                k_per_nine: k_per_nine,
                bb_per_nine: bb_per_nine,
                k_bb: k_bb
              )
            end
          end
        else # * 野手の場合: 野手成績を取得
          doc.css(".registerStats").each do |stats_row|
            # 取得したい年度を指定し、それ以外は扱わない
            year = stats_row.at_css(".year").text.strip.to_i
            next unless year == target_year

            # 各野手成績を取得
            team = stats_row.at_css("td:nth-of-type(2)").text.strip
            games = stats_row.at_css("td:nth-of-type(3)").text.strip.to_i
            plate_appearances = stats_row.at_css("td:nth-of-type(4)").text.strip.to_i
            at_bats = stats_row.at_css("td:nth-of-type(5)").text.strip.to_i
            runs = stats_row.at_css("td:nth-of-type(6)").text.strip.to_i
            hits = stats_row.at_css("td:nth-of-type(7)").text.strip.to_i
            doubles = stats_row.at_css("td:nth-of-type(8)").text.strip.to_i
            triples = stats_row.at_css("td:nth-of-type(9)").text.strip.to_i
            home_runs = stats_row.at_css("td:nth-of-type(10)").text.strip.to_i
            total_bases = stats_row.at_css("td:nth-of-type(11)").text.strip.to_i
            rbi = stats_row.at_css("td:nth-of-type(12)").text.strip.to_i
            stolen_bases = stats_row.at_css("td:nth-of-type(13)").text.strip.to_i
            caught_stealing = stats_row.at_css("td:nth-of-type(14)").text.strip.to_i
            sacrifice_bunts = stats_row.at_css("td:nth-of-type(15)").text.strip.to_i
            sacrifice_flies = stats_row.at_css("td:nth-of-type(16)").text.strip.to_i
            walks = stats_row.at_css("td:nth-of-type(17)").text.strip.to_i
            hit_by_pitch = stats_row.at_css("td:nth-of-type(18)").text.strip.to_i
            strikeouts = stats_row.at_css("td:nth-of-type(19)").text.strip.to_i
            gidp = stats_row.at_css("td:nth-of-type(20)").text.strip.to_i
            avg = stats_row.at_css("td:nth-of-type(21)").text.strip.to_f
            slg = stats_row.at_css("td:nth-of-type(22)").text.strip.to_f
            obp = stats_row.at_css("td:nth-of-type(23)").text.strip.to_f
            ops = cal_ops(slg, obp)
            k_percentage = cal_k_percentage(strikeouts, plate_appearances)
            bb_percentage = cal_bb_percentage(walks, plate_appearances)
            bb_k = cal_bb_k(walks, strikeouts)

            # BattingStatが存在するか確認し、存在しない場合は新規作成
            if player.batting_stat.present?
              player.batting_stat.update(
                year: year,
                team: team,
                games: games,
                plate_appearances: plate_appearances,
                at_bats: at_bats,
                runs: runs,
                hits: hits,
                doubles: doubles,
                triples: triples,
                home_runs: home_runs,
                total_bases: total_bases,
                rbi: rbi,
                stolen_bases: stolen_bases,
                caught_stealing: caught_stealing,
                sacrifice_bunts: sacrifice_bunts,
                sacrifice_flies: sacrifice_flies,
                walks: walks,
                hit_by_pitch: hit_by_pitch,
                strikeouts: strikeouts,
                gidp: gidp,
                avg: avg,
                slg: slg,
                obp: obp,
                ops: ops,
                k_percentage: k_percentage,
                bb_percentage: bb_percentage,
                bb_k: bb_k
              )
            else
              player.create_batting_stat(
                year: year,
                team: team,
                games: games,
                plate_appearances: plate_appearances,
                at_bats: at_bats,
                runs: runs,
                hits: hits,
                doubles: doubles,
                triples: triples,
                home_runs: home_runs,
                total_bases: total_bases,
                rbi: rbi,
                stolen_bases: stolen_bases,
                caught_stealing: caught_stealing,
                sacrifice_bunts: sacrifice_bunts,
                sacrifice_flies: sacrifice_flies,
                walks: walks,
                hit_by_pitch: hit_by_pitch,
                strikeouts: strikeouts,
                gidp: gidp,
                avg: avg,
                slg: slg,
                obp: obp,
                ops: ops,
                k_percentage: k_percentage,
                bb_percentage: bb_percentage,
                bb_k: bb_k
              )
            end
          end
        end

        puts "Updated player data for #{name}"
      rescue => e
        puts "Failed to scrape data for #{name}, Error: #{e.message}"
        # puts "Backtrace: #{e.backtrace.join("\n")}" # * エラーの場所がわからないときは有効化
      end

      # ! 各リクエストの間に待機時間を設定
      sleep(1)
    end
  end

  # * 投球回数を特別に抽出
  # * td_element は class="registerStats"の子要素を指定
  # * 2024年10月18日現在は14番目のtd要素
  def self.extract_innings(td_element)
    innings_major = td_element.at_css("table.table_inning th")
    innings_minor = td_element.at_css("table.table_inning td")

    if innings_major
      innings_major = innings_major.text.strip.to_i
    else
      innings_major = 0
    end
    if innings_minor
      innings_minor = innings_minor.text.strip.to_f
    else
      innings_minor = 0.0
    end
    # 例: 57 + 0.1 = 57.1
    innings_major + innings_minor
  end

  # * WHIPを計算するメソッド
  def self.cal_whip(walks, hits, innings)
    temp = innings.to_i
    if (innings - temp) > 0.09 && (innings - temp) < 0.11
      innings += ((1.0 / 3) - 0.1)
    elsif (innings - temp > 0.19) && (innings - temp) < 0.21
      innings += ((2.0 / 3) - 0.2)
    end
    (walks + hits) / innings.to_f
  end

  # * 奪三振率を計算するメソッド
  def self.cal_k_per_nine(strikeouts, innings)
    temp = innings.to_i
    if (innings - temp) > 0.09 && (innings - temp) < 0.11
      innings += ((1.0 / 3) - 0.1)
    elsif (innings - temp > 0.19) && (innings - temp) < 0.21
      innings += ((2.0 / 3) - 0.2)
    end
    strikeouts * 9 / innings.to_f
  end

  # * 与四球率を計算するメソッド
  def self.cal_bb_per_nine(walks, innings)
    temp = innings.to_i
    if (innings - temp) > 0.09 && (innings - temp) < 0.11
      innings += ((1.0 / 3) - 0.1)
    elsif (innings - temp > 0.19) && (innings - temp) < 0.21
      innings += ((2.0 / 3) - 0.2)
    end
    walks * 9 / innings.to_f
  end

  # * K/BBを計算するメソッド
  def self.cal_k_bb(strikeouts, walks)
    strikeouts / walks.to_f
  end

  # * OPSを計算するメソッド
  def self.cal_ops(slg, obp)
    slg + obp
  end

  # * K%を計算するメソッド
  def self.cal_k_percentage(strikeouts, plate_appearances)
    strikeouts / plate_appearances.to_f
  end

  # * BB%を計算するメソッド
  def self.cal_bb_percentage(walks, plate_appearances)
    walks / plate_appearances.to_f
  end

  # * BB/Kを計算するメソッド
  def self.cal_bb_k(walks, strikeouts)
    walks / strikeouts.to_f
  end

  # * 指定したノードをスクレイピングし、適切な形式で保持するメソッド
  # todo 使わないかもしれないので、いらなかったら消去する
  def scrape_node(doc, css_selector, format_type = "")
    node = doc.at_css(css_selector)

    # ノードが存在するかチェック
    if node
      text = node.text.strip
      case format_type
      when "i"
        text.to_i
      when "f"
        text.to_f
      else
        text
      end
    else
      nil # ノードが見つからない場合はnilを返す
    end
  end
end
