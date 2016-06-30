# The base class of all symbolic values
class SymbolicValue
  def initialize(name)
    @name = name
  end
  def ==(other)
    puts "#{name} was compared to #{other}"
  end
end