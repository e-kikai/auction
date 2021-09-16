class AterAbtestsIp < ActiveRecord::Migration[5.2]
  def change
    add_column :abtests,      :ip,    :string
    add_column :abtests,      :host,  :string
  end
end
