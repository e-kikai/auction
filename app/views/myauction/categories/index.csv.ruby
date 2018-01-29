["ID", "カテゴリ名", "階層構造"].to_csv +
@categories.sum do |ca|
  [ca.id, ca.name, "/" + ca.ancestors.map{ |g| g.name }.join("/")].to_csv
end
