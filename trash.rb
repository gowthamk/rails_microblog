class SymbolicUserId
  #extend ObjectTracker
  def initialize
    #@number = :sym_number
  end
=begin
  def id
    self
  end
=end
=begin
  def quoted_id
    self
  end
=end
  def to_s
    "sym_user_id"
  end
=begin
  def to_ary
    [self]
  end
=end
=begin
  def == other
    puts "Asked if equal to #{other}"
    x = super
    puts "Returning #{x}"
  end
=end
=begin
  def !
    puts "Called !"
    x = super
    puts "Returning #{x}"
  end
=end
  def respond_to? *args
    puts "Called respond_to? with #{args}"
    x = super
    puts "Returning #{x}"
    x
  end
  def method_missing(name, *args, &blk)
    puts "#{name} method is missing"
  end
  def to_i(*args)
    puts "to_i called with args=#{args}"
    self
  end
end