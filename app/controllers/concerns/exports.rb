module Exports
  extend ActiveSupport::Concern

  require 'nkf'

  ### 共通CSVエクスポート処理 ###
  def export_csv(filename = nil, path = nil)
    send_data NKF::nkf('--sjis -Lw', render_to_string(path)),
      content_type: 'text/csv;charset=shift_jis',
      filename: filename_encode(filename)
  end

  ### ファイル名エンコード ###
  def filename_encode(filename)
    if (/MSIE/ =~ request.user_agent) || (/Trident/ =~ request.user_agent)
      ERB::Util.url_encode(filename)
    else
      filename
    end
  end
end
