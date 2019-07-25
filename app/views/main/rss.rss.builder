xml.instruct! :xml, :version => "1.0"
xml.rss(
  "version"       => "2.0",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw"     => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc"      => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom"    => "http://www.w3.org/2005/Atom",
  "xmlns:sy"      => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash"   => "http://purl.org/rss/1.0/modules/slash/"
) do
  xml.channel do
    xml.title "ものづくりオークション"
    xml.description "新品も中古も！欲しかったあの工具が格安で手に入るかも！ものづくりの現場で活躍する機械・工具を安心安全な業者からネットオークションで購入！"
    xml.link "https://www.mnok.net/"
    xml.language "ja-ja"
    xml.ttl "40"
    xml.pubDate(Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z"))
    xml.copyright "Copyright (c) #{Time.now.year} 任意団体ものづくりオークション委員会, All Rights reserved."
    xml.atom :link, "href" => "https://www.mnok.net/feed.rss", "rel" => "self", "type" => "application/rss+xml"
    xml.image asset_url("logo_03.png")

    @products.each do |p|
      desc = "<div>"
      unless p.prompt_dicision?
        desc += "現在 : #{number_to_currency(p.max_price_with_tax)}"
      end
      if p.prompt_dicision_price.present?
        desc += " 即決 : #{number_to_currency(p.prompt_dicision_price_with_tax)}"
      end
      desc += " / #{I18n.l(p.dulation_end, format: :full_date)} 終了</div>"
      desc += "<div>出品会社 : #{p.user.company}</div>"

      desc += "<div>#{p.description}</div>" if p.description.present?

      xml.item do
        xml.title p.name
        xml.description do
          xml.cdata! desc
        end
        xml.pubDate p.dulation_start # 開始日
        xml.link "https://www.mnok.net/products/#{p.id}"
        xml.guid "https://www.mnok.net/products/#{p.id}", "isPermaLint" => true
        xml.enclosure "", "url" => p.thumb_url, "length" => "100000", "type" => "image/jpeg"
        xml.media(:content, "url" => p.thumb_url, "medium" => "image", "type" => "image/jpeg")
        xml.category p.category.name
      end
    end
  end
end
