require 'active_record'
require 'transaction_retry'
require 'benchmark'
require 'logger'
require_relative 'app/models/user'
require_relative 'app/models/micropost'
require_relative 'my_real_transaction'

my_logger = Logger.new('log/experiments.log')
my_logger.level= Logger::DEBUG
ActiveRecord::Base.logger = my_logger
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
ActiveRecord::Base.connection.execute("TRUNCATE TABLE users")
TransactionRetry.apply_activerecord_patch
TransactionRetry.max_retries=10
$level = :read_committed
user = User.new(name:'buddha', email:'buddha@buddhism.org', password:'zenisfun')
user.save

nClients = 4
for i in 1..10
  nClients.times do
    Process.fork do
      pk = Process.pid
      usr = User.new(name:"buddha#{i}", email:"buddha#{i}@buddhism.org", password:'zenisfun')
      ttkn = Benchmark.realtime {
        usr.save
      }
    end
  end
  Process.waitall
end

ActiveRecord::Base.remove_connection
ActiveRecord::Base.establish_connection(configuration['development'])
dups = ActiveRecord::Base.connection.execute("SELECT email, COUNT(email)-1 FROM users GROUP BY email HAVING COUNT(email) > 1")

sum = 0
dups.each do |dp|
  count = dp["?column?"]
  sum = sum + Integer(count)
end

puts "#{sum} duplicates detected!"
