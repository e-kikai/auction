["ID", "カテゴリ名", "階層構造"].to_csv +
@categories.sum do |ca|
  [ca.id, ca.name, ca.ancestor_names].to_csv
end
