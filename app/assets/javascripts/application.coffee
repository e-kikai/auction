# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
# vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https:#github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require rails-ujs
#= require bootstrap-sass
#= require bootstrap-fileinput
#= require moment
#= require moment/locale/ja
#= require turbolinks
# require_tree .

$(document).on 'turbolinks:load', ->
  ### Google Analyticsの設定(turbolinks5対応) ###

  if window.ga?
    ga('set', 'location', location.href.split('#')[0])
    ga('send', 'pageview')

  if !$("#nologging").val()
    ### 詳細ページログ取得 ###
    if $("body").data("controller") == "products" && $("body").data("action") == "show"
      $.ajax
        async:    true
        url:      "/detail_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { product_id : $('#product_id').val(), r : $('#r').val(), referer : $('#referer').val()  },
        timeout:  3000,
        # success:  (data, status, xhr)   -> alert status
        # error:    (xhr,  status, error) -> alert status

    ### 検索ログ ###
    if $("body").data("controller") == "products" && $("body").data("action") == "index"
      $.ajax
        async:    true
        url:      "/search_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { category_id : $('#search_category_id').val(), company_id : $('#search_company_id').val(), keywords : $('#search_keywords').val(), search_id : $('#search_id').val(), r : $('#r').val(), referer : $('#referer').val() },
        timeout:  3000,
        # success:  (data, status, xhr)   -> alert status
        # error:    (xhr,  status, error) -> alert status

    ### トップページログ ###
    if $("body").data("controller") == "main" && $("body").data("action") == "index"
      $.ajax
        async:    true
        url:      "/toppage_logs/"
        type:     'POST',
        dataType: 'json',
        data :    { r : $('#r').val(), referer : $('#referer').val() },
        timeout:  3000,
        # success:  (data, status, xhr)   -> alert status
        # error:    (xhr,  status, error) -> alert status

  # # フォーム共通 : フォーム自動全選択
  # $('input.allselect').click ->
  #   @.select()

  # # フォーム共通 : datetimepicker
  # $('input.datepicker').datetimepicker({locale: 'ja', format: 'YYYY/MM/DD'})
  # $('input.datetimepicker').datetimepicker({locale: 'ja', format: 'YYYY/MM/DD HH:mm:ss'})

  # # テーブルスクロール制御
  # FixedMidashi.create()

  ### スクロールボタン ###
  $_topBtn = $('#page-top')
  $_topBtn.hide()

  # スクロールが100に達したらボタン表示
  $(window).scroll ->
    if $(this).scrollTop() > 100
      $_topBtn.fadeIn()
    else
      $_topBtn.fadeOut()

  # スクロールしてトップ
  $_topBtn.click ->
    $('body,html').animate({ scrollTop: 0 }, 500)
    return false

  # カンマ区切り処理 : フォーカスを得たとき
  $("input.price").focus ->
    $(@).val(priceUnformat($(@).val()))

  # カンマ区切り処理 : フォーカスを失ったとき
  $("input.price").blur ->
    $(@).val(priceFormat($(@).val()))

  # カンマ区切り処理 : 初期化
  $("input.price").each ->
    $(this).triggerHandler "blur"

  # カンマ区切り処理 : フォームのアップロード
  $("form").submit ->
    $(@).find("input.price").each ->
      $(this).triggerHandler "focus"

  # スマートフォンのみcollapseを閉じておく
  if window.matchMedia('(max-width: 767px)').matches
    console.log($(".xs-close").collapse('hide'))
  if window.matchMedia('(max-width: 991px)').matches
    console.log($(".sm-close").collapse('hide'))

  # youtube modal #
  $('.youtube_viewer').click ->
    src = $(@).attr('data-video')

    $('#youtubeModal').modal("show")
    $('#youtubeModal iframe').attr("src", src)

    return false

  $('#youtubeModal').on 'hide.bs.modal', ->
    $("#youtubeModal iframe").attr("src", '')

  # スマートフォンのみcollapseを閉じておく
  if window.matchMedia('(max-width: 767px)').matches
    console.log($(".xs-close").collapse('hide'))
  if window.matchMedia('(max-width: 991px)').matches
    console.log($(".sm-close").collapse('hide'))


priceUnformat = (str) ->
  num = new String(str).replace(/[^0-9]/g, "")
  num = "" if num == '0'
  return num

priceFormat = (str) ->
  num = "" + priceUnformat(str)
  while num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2"))
    num
  return num
