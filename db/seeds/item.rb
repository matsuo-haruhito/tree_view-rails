ITEM_CSV_HEADERS = %w[親商品名 商品名 コメント].freeze

def item
  rows = read_item_rows
  validate_item_rows!(rows)
  import_item_rows!(rows)
end

def read_item_rows
  csv_file_path = File.expand_path('../data/item.csv', __FILE__)
  csv = CSV.read(csv_file_path, headers: true)

  unless (ITEM_CSV_HEADERS - csv.headers).empty?
    missing = ITEM_CSV_HEADERS - csv.headers
    raise "item.csv のヘッダが不足しています: #{missing.join(', ')}"
  end

  csv.map.with_index(2) do |row, line_no|
    {
      line_no: line_no,
      parent_name: normalize_seed_value(row['親商品名']),
      name: normalize_seed_value(row['商品名']),
      comment: normalize_seed_value(row['コメント'])
    }
  end
end

def validate_item_rows!(rows)
  blank_name_rows = rows.select { |row| row[:name].nil? }
  raise "item.csv に商品名が空の行があります: #{blank_name_rows.map { |r| r[:line_no] }.join(', ')}" if blank_name_rows.any?

  self_parent_rows = rows.select { |row| row[:parent_name].present? && row[:parent_name] == row[:name] }
  raise "item.csv に自己参照行があります: #{self_parent_rows.map { |r| r[:line_no] }.join(', ')}" if self_parent_rows.any?

  duplicate_name_rows = rows.group_by { |row| row[:name] }.select { |_name, group| group.size > 1 }
  if duplicate_name_rows.any?
    lines = duplicate_name_rows.values.flat_map { |group| group.map { |row| row[:line_no] } }.sort
    raise "item.csv に同名の商品があります: #{lines.join(', ')}"
  end

  duplicates = rows.group_by { |row| [row[:parent_name], row[:name], row[:comment]] }.select { |_k, v| v.size > 1 }
  if duplicates.any?
    lines = duplicates.values.flat_map { |group| group.map { |row| row[:line_no] } }.sort
    raise "item.csv に重複行があります: #{lines.join(', ')}"
  end
end

def import_item_rows!(rows)
  items_by_name = Item.all.index_by(&:name)

  pending = rows.dup
  attempts = 0

  while pending.any?
    attempts += 1
    progressed = false
    next_pending = []

    pending.each do |row|
      parent = resolve_parent_item(row[:parent_name], items_by_name)
      if row[:parent_name].present? && parent.nil?
        next_pending << row
        next
      end

      item_record = upsert_item_row(row, parent, items_by_name)
      items_by_name[item_record.name] = item_record
      progressed = true
    end

    if !progressed
      unresolved = next_pending.map { |row| "#{row[:line_no]}行目(parent=#{row[:parent_name]})" }
      raise "item.csv の親参照を解決できません: #{unresolved.take(10).join(', ')}"
    end

    pending = next_pending
    raise 'item.csv の読み込み試行回数が上限に達しました' if attempts > rows.size + 2
  end
end

def resolve_parent_item(parent_name, items_by_name)
  return nil if parent_name.blank?

  items_by_name[parent_name]
end

def upsert_item_row(row, parent, items_by_name)
  item_record = items_by_name[row[:name]] || Item.new(name: row[:name])
  item_record.comment = row[:comment]
  item_record.parent_item_id = parent&.id
  item_record.save! if item_record.new_record? || item_record.changed?
  item_record
end

def normalize_seed_value(value)
  text = value.to_s.strip
  text.present? ? text : nil
end
