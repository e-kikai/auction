["id", "name", "parent_id", "parent_name", "count"].to_csv +
@categories.sum do |ca|
  [
    ca.id, ca.name, ca.parent_id, ca.parent&.name, ca.products&.count
  ].to_csv
end
