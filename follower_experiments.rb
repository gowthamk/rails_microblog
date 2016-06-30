require 'active_record'
require 'transaction_retry'
require 'benchmark'
require 'logger'
require_relative 'app/models/user'
require_relative 'app/models/micropost'
require_relative 'app/models/relationship'
require_relative 'my_real_transaction'

my_logger = Logger.new('log/experiments.log')
#my_logger.level= Logger::DEBUG
ActiveRecord::Base.logger = my_logger
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
ActiveRecord::Base.connection.execute("TRUNCATE TABLE users")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE relationships")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE microposts")
TransactionRetry.apply_activerecord_patch
TransactionRetry.max_retries=10
$level = :read_committed

nUsers = 100
nClients = 4
nTweetsPerUser = 10
nFollowed = 20

for i in 1..nUsers
  usr = User.new(name:"buddha#{i}", email:"buddha#{i}@buddhism.org", password:'zenisfun')
  usr.save
  for j in 1..nTweetsPerUser
    post = usr.microposts.build(content: "tweeeet")
    post.save
  end
end

for i in 1..nUsers
  me = User.where(email: "buddha#{i}@buddhism.org").take
  followed = [*1..(i-1), *(i+1)..nUsers].sample(nFollowed)
  followed.each do |followed_id|
    other = User.where(email: "buddha#{followed_id}@buddhism.org").take
    me.follow! other
  end
end

puts "Insertion Done"

nDeletions = 4
nReads = 10
deletions = (1..nUsers).to_a.sample(nDeletions)
reads = ((1..nUsers).to_a - deletions).sample(nReads)

puts "Deletions: #{deletions}"
puts "Reads: #{reads}"

deletions.each do |i|
  Process.fork do
    usr = User.where(email: "buddha#{i}@buddhism.org").take
    usr.destroy
  end
end

reads.each do |j|
  Process.fork do
    $level = :read_committed
    ActiveRecord::Base.transaction do
      me = User.where(email: "buddha#{j}@buddhism.org").take
      me.feed.each do |post|
        if post.user.nil? then
          puts "post has no author!"
        end
      end
    end
  end
end

Process.waitall

puts "Done!"