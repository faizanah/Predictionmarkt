require 'socket'

deploy_to = "/var/www/predictionmarkt"
rails_env = ENV['RAILS_ENV'] || 'production'

if rails_env == 'development'
  current_path = shared_path = Dir.pwd
else
  current_path = "#{deploy_to}/current"
  shared_path = "#{deploy_to}/shared"
end
# if RUBY_VERSION > '1.9'
#   shared_bundler_gems_path = "#{shared_path}/bundle/ruby/2.0.0"
# else
#   shared_bundler_gems_path = "#{shared_path}/bundle/ruby/1.9.1"
# end
#
# See http://unicorn.bogomips.org/Sandbox.html
# Helps ensure the correct unicorn_rails is used when upgrading with USR2
# Unicorn::HttpServer::START_CTX[0] = "#{shared_bundler_gems_path}/bin/unicorn_rails"

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 3

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.
working_directory current_path

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
# listen "/tmp/.sock", :backlog => 64
listen "0.0.0.0:4004"
# localip = Socket.ip_address_list.detect{ |intf| intf.ipv4_private? }.ip_address
# listen "#{localip}:3000" if localip && localip =~ /\.42\./

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 900

# feel free to point this anywhere accessible on the filesystem
pid "#{shared_path}/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{shared_path}/log/unicorn.stderr.log"
stdout_path "#{shared_path}/log/unicorn.stdout.log"

# combine REE with "preload_app true" for memory savings
# http://rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
preload_app true
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  #
  # # *optionally* throttle the master from forking too quickly by sleeping
  # sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection

  srand

  # Looks like redis 4 does not need reconnect?
  # Redis.current.client.reconnect

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end

# before_exec do |server|
#   paths = (ENV["PATH"] || "").split(File::PATH_SEPARATOR)
#   paths.unshift "#{shared_bundler_gems_path}/bin"
#   ENV["PATH"] = paths.uniq.join(File::PATH_SEPARATOR)
#
#   ENV['GEM_HOME'] = ENV['GEM_PATH'] = shared_bundler_gems_path
#   ENV['BUNDLE_GEMFILE'] = "#{current_path}/Gemfile"
# end
