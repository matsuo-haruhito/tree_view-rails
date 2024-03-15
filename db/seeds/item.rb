def item
  # CSVファイルのパス
  csv_file_path = File.expand_path('../data/item.csv', __FILE__)

  # 親商品が登録されていない商品のみを保持するための配列
  unassociated_items = []

  # CSVファイルを読み込んで処理を行う
  #loop do
    csv_data = CSV.read(csv_file_path, headers: true)
    p csv_data
    #break if csv_data.empty? # CSVファイルが空の場合は処理を終了する

    csv_data.each do |row|
      p row
      parent_item_name = row['親商品名']
      item_name = row['商品名']
      comment = row['コメント']

      # 同じ商品名とコメントを持つ商品がすでに登録されているかを確認する
      existing_item = Item.find_by(name: item_name, comment: comment)

      if existing_item
        # すでに登録されている場合はスキップする
        next
      end

      if parent_item_name.nil?
        # 親商品が指定されていない場合は、新しい商品を作成する
        p "nil"
        p parent_item_name
        item = Item.create(name: item_name, comment: comment)
        unassociated_items << item
      else
        p "not nil"
        p parent_item_name
        # 親商品が指定されている場合は、親商品を検索して関連付けを行う
        parent_item = Item.find_by(name: parent_item_name)
        if parent_item
          # 親商品が見つかった場合は、子商品を作成し、親子関係を構築する
          item = parent_item.children.create(name: item_name, comment: comment)
          unassociated_items.delete(item) # 親子関係が成立したので、unassociated_itemsから削除する
        else
          # 親商品が見つからなかった場合は、子商品を一時的にunassociated_itemsに追加する
          unassociated_items << Item.create(name: item_name, comment: comment)
        end
      end
    end

    # 全てのデータが取り込み終わったか、親商品が登録されていない商品のみになったかをチェックする
    #break if unassociated_items.empty?
  end
#end
