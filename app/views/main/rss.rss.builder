xml.instruct! :xml, :version => "1.0"
xml.rss(
  "version"       => "2.0",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw"     => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc"      => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom"    => "http://www.w3.org/2005/Atom",
  "xmlns:sy"      => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash"   => "http://purl.org/rss/1.0/modules/slash/",
  "xmlns:media"   => "http://search.yahoo.com/mrss/"
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
    xml.image do
      xml.url asset_url("logo_03.png")
      xml.title "ものづくりオークション ものづくりのための中古機械・工具のオークション"
      xml.link "https://www.mnok.net/"
    end

    @products.each do |p|
      if params[:mail]
        # desc_tmp = "<div style='font-size: 14px;display: inline-block;padding: 0 4px;line-height: 1.4;;margin: 0;background:#FFF;border:1px solid #333;color:#333;border-radius:4px;'>#{p.state}</div>"
        # desc_tmp = "  <span style="color: #333;font-size: 11px;">入札</span><span style="margin-left: 4px;color: #333;margin-right: 8px;">#{p.bids_count > 0 ? number_with_delimiter(p.bids_count) : "-"}</span>"

        desc = <<"EOS"
<div style='color:#333;width: 190px;'>
  <span style='olor:#333;font-size: 11px;'>現在</span>
  <span style="font-size: 17px;margin-left: 4px;color: #E50;font-weight: normal;">#{number_to_currency(p.max_price_with_tax)}</span>
</div>
<div style="width: 190px;">
  <span style="color: #333;font-size: 11px;">残り時間</span>
  <span style="margin-left: 4px;color: #333;">#{p.remaining_time}</span>
</div>
EOS
      else
        desc = ""
        unless p.prompt_dicision?
          desc += "現在価格 : #{number_to_currency(p.max_price_with_tax)}"
        end
        if p.prompt_dicision_price.present?
          desc += " 即売価格 : #{number_to_currency(p.prompt_dicision_price_with_tax)}"
        end
        desc += " 終了日時 : #{I18n.l(p.dulation_end, format: :full_date)}"
        desc += " 出品会社 : #{p.user.company}"

        desc += " #{p.description}" if p.description.present?
      end

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
