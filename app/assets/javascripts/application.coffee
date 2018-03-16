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

### Google Analyticsの設定(turbolinks5対応) ###
$ ->
  $(document).on 'turbolinks:render', ->
    if window.ga?
      ga('set', 'location', location.href.split('#')[0])
      ga('send', 'pageview')

$(document).on 'ready, turbolinks:load', ->
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


priceUnformat = (str) ->
  num = new String(str).replace(/[^0-9]/g, "")
  num = "" if num == '0'
  return num

priceFormat = (str) ->
  num = "" + priceUnformat(str)
  while num != (num = num.replace(/^(-?\d+)(\d{3})/, "$1,$2"))
    num
  return num
