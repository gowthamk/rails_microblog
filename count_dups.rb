require 'active_record'

my_logger = Logger.new('log/experiments.log')
my_logger.level= Logger::DEBUG
ActiveRecord::Base.logger = my_logger
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
dups = ActiveRecord::Base.connection.execute("SELECT email, COUNT(email)-1 FROM users GROUP BY email HAVING COUNT(email) > 1")

sum = 0
dups.each do |dp|
  count = dp["?column?"]
  sum = sum + Integer(count)
end

puts "#{sum} duplicates detected!"
