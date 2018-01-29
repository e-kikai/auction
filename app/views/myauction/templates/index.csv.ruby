["ID", "テンプレート名"].to_csv +
@templates.sum do |tp|
  [tp.id, tp.name].to_csv
end
