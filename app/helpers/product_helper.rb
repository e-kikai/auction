module ProductHelper
  ### ウォッチボタン生成 ###
  def watch(product, r="")
    unless product.finished?
      if user_signed_in?
        ac, ti = if current_user.watch?(product.id)
          ["active", "ウォッチリストから削除"]
        else
          ["", "ウォッチリストに登録"]
        end

        link_to("/myauction/watches/toggle?id=#{product.id}&r=#{r}",
          method: :post, remote: true, class: "watch_02 #{ac}",
          data: { pid: product.id, toggle: :tooltip, container: :html, placement: :left, trigger: :hover },
          title: ti) do
          tag.span class: "glyphicon glyphicon-star"
        end

      else
        link_to("/users/sign_in", class: "watch_02",
          data: { pid: product.id, totoggle: :tooltip, container: :html, placement: :left,
            trigger: :hover, html: :true },
          title: "ログインすると<br />ウォッチリストを利用できます") do
          tag.span class: "glyphicon glyphicon-star"
        end
      end
    end
  end

  ### 似たものソートボタン生成 ###
  def nitamono_sort(product)
    if params[:nitamono].to_i == product.id
      tag.div class: "nitamono target" do
        tag.span(class: "glyphicon glyphicon-camera") +
        tag.div("この写真と似たもの順", class: "nitamono_label")
      end
    else
      link_to(url_for(@pms.merge(nitamono: product.id)), class: "nitamono",
        data: { toggle: :tooltip, container: :html, placement: :left, html: true, trigger: :hover }, title: "この写真と似たもの順で並び替え") do
        tag.span class: "glyphicon glyphicon-camera"
      end
    end
  end
end
