header = ["送料名称"]
@labels.map { |la| header[la.shipping_no] = la.name }

temp = {}
@fees.each { |fe| temp[[fe.addr_1, fe.shipping_no]] = fe.price }

(header).to_csv +
ShippingFee::ADDRS.sum do |addr_1|
  ([addr_1] + @labels.map {|he| temp[[addr_1, he.shipping_no]] }).to_csv
end
