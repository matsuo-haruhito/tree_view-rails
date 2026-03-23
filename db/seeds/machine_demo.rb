MACHINE_DEMO_CSV_HEADERS = %w[親種別 親名称 種別 名称].freeze
MACHINE_DEMO_TYPES = %w[Machine Unit Part Material].freeze

def machine_demo
  rows = read_machine_demo_rows
  validate_machine_demo_rows!(rows)
  import_machine_demo_rows!(rows)
end

def read_machine_demo_rows
  csv_file_path = File.expand_path('../data/machine_demo.csv', __FILE__)
  csv = CSV.read(csv_file_path, headers: true)

  unless (MACHINE_DEMO_CSV_HEADERS - csv.headers).empty?
    missing = MACHINE_DEMO_CSV_HEADERS - csv.headers
    raise "machine_demo.csv のヘッダが不足しています: #{missing.join(', ')}"
  end

  csv.map.with_index(2) do |row, line_no|
    {
      line_no: line_no,
      parent_type: normalize_machine_seed_value(row['親種別']),
      parent_name: normalize_machine_seed_value(row['親名称']),
      type: normalize_machine_seed_value(row['種別']),
      name: normalize_machine_seed_value(row['名称'])
    }
  end
end

def validate_machine_demo_rows!(rows)
  blank_rows = rows.select { |row| row[:type].nil? || row[:name].nil? }
  raise "machine_demo.csv に必須列が空の行があります: #{blank_rows.map { |r| r[:line_no] }.join(', ')}" if blank_rows.any?

  invalid_type_rows = rows.select { |row| !MACHINE_DEMO_TYPES.include?(row[:type]) }
  if invalid_type_rows.any?
    raise "machine_demo.csv に未対応種別があります: #{invalid_type_rows.map { |r| "#{r[:line_no]}行目(#{r[:type]})" }.join(', ')}"
  end

  invalid_parent_type_rows = rows.select { |row| row[:parent_type].present? && !MACHINE_DEMO_TYPES.include?(row[:parent_type]) }
  if invalid_parent_type_rows.any?
    raise "machine_demo.csv に未対応の親種別があります: #{invalid_parent_type_rows.map { |r| "#{r[:line_no]}行目(#{r[:parent_type]})" }.join(', ')}"
  end

  parent_pair_invalid = rows.select { |row| row[:parent_type].present? ^ row[:parent_name].present? }
  if parent_pair_invalid.any?
    raise "machine_demo.csv は親種別と親名称を同時指定してください: #{parent_pair_invalid.map { |r| r[:line_no] }.join(', ')}"
  end

  duplicates = rows.group_by { |row| [row[:type], row[:name]] }.select { |_key, group| group.size > 1 }
  if duplicates.any?
    dup_lines = duplicates.values.flat_map { |group| group.map { |row| row[:line_no] } }.sort
    raise "machine_demo.csv に同一種別+名称の重複があります: #{dup_lines.join(', ')}"
  end
end

def import_machine_demo_rows!(rows)
  index = {
    'Machine' => Machine.all.index_by(&:name),
    'Unit' => Unit.all.index_by(&:name),
    'Part' => Part.all.index_by(&:name),
    'Material' => Material.all.index_by(&:name)
  }

  pending = rows.dup
  attempts = 0

  while pending.any?
    attempts += 1
    progressed = false
    next_pending = []

    pending.each do |row|
      parent = resolve_machine_demo_parent(row, index)
      if row[:parent_type].present? && parent.nil?
        next_pending << row
        next
      end

      record = upsert_machine_demo_row(row, parent, index)
      index[row[:type]][record.name] = record
      progressed = true
    end

    if !progressed
      unresolved = next_pending.map { |row| "#{row[:line_no]}行目(#{row[:parent_type]}:#{row[:parent_name]})" }
      raise "machine_demo.csv の親参照を解決できません: #{unresolved.take(10).join(', ')}"
    end

    pending = next_pending
    raise 'machine_demo.csv の読み込み試行回数が上限に達しました' if attempts > rows.size + 2
  end
end

def resolve_machine_demo_parent(row, index)
  return nil if row[:parent_type].blank?

  index[row[:parent_type]][row[:parent_name]]
end

def upsert_machine_demo_row(row, parent, index)
  case row[:type]
  when 'Machine'
    upsert_machine_row(row, parent)
  when 'Unit'
    upsert_unit_row(row, parent)
  when 'Part'
    upsert_part_row(row, parent)
  when 'Material'
    upsert_material_row(row, parent)
  else
    raise "未対応種別: #{row[:type]}"
  end
end

def upsert_machine_row(row, parent)
  if row[:parent_type].present? && row[:parent_type] != 'Machine'
    raise "machine_demo.csv #{row[:line_no]}行目: Machine の親は Machine のみ指定可能です"
  end

  machine = Machine.find_or_initialize_by(name: row[:name])
  machine.parent_machine = parent
  machine.save! if machine.new_record? || machine.changed?
  machine
end

def upsert_unit_row(row, parent)
  unless %w[Machine Unit].include?(row[:parent_type])
    raise "machine_demo.csv #{row[:line_no]}行目: Unit の親は Machine または Unit を指定してください"
  end

  unit = Unit.find_or_initialize_by(name: row[:name])
  if row[:parent_type] == 'Machine'
    unit.machine = parent
    unit.parent_unit = nil
  else
    unit.machine = parent.machine
    unit.parent_unit = parent
  end
  unit.save! if unit.new_record? || unit.changed?
  unit
end

def upsert_part_row(row, parent)
  unless %w[Machine Unit].include?(row[:parent_type])
    raise "machine_demo.csv #{row[:line_no]}行目: Part の親は Machine または Unit を指定してください"
  end

  part = Part.find_or_initialize_by(name: row[:name])
  if row[:parent_type] == 'Machine'
    part.machine = parent
    part.unit = nil
  else
    part.machine = parent.machine
    part.unit = parent
  end
  part.save! if part.new_record? || part.changed?
  part
end

def upsert_material_row(row, parent)
  if row[:parent_type] != 'Part'
    raise "machine_demo.csv #{row[:line_no]}行目: Material の親は Part を指定してください"
  end

  material = Material.find_or_initialize_by(name: row[:name])
  material.part = parent
  material.save! if material.new_record? || material.changed?
  material
end

def normalize_machine_seed_value(value)
  text = value.to_s.strip
  text.present? ? text : nil
end
