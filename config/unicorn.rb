# -*- coding: utf-8 -*-

# unicornのプロセスがリスンするアドレスとポートを指定
# listen "127.0.0.1:3001"
# listen 3001, :tcp_nopush => false

# pid fileの位置を指定する
# pid "/run/unicorn_e-kikai.pid"
ROOT = "#{File.dirname(__FILE__)}/.."
pid "#{ROOT}/tmp/pids/unicorn.pid"

# ワーカーの数を指定する
worker_processes 3

# リクエストのタイムアウト秒を指定する
timeout 3600

# ダウンタイムなくすため、アプリをプレロード
preload_app true

# unicornのログ出力先を指定
# stdout_path "/var/log/unicorn-access.log"
# stderr_path "/var/log/unicorn-error.log"
stderr_path "#{ROOT}/log/unicorn.stderr.log"
stdout_path "#{ROOT}/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      Process.kill :QUIT, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
