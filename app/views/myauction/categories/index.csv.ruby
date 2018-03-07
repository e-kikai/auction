categories = Category.all.index_by(&:id)

["ID", "カテゴリ名", "階層構造"].to_csv +
@categories.sum do |ca|
  [ca.id, ca.name, ca.ancestor_ids.map { |v| categories[v].name rescue "" }.join(" > ")].to_csv
end
