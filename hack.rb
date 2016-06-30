# We define our own integer class, which denotes a symbolic
# integer returned by SQL query "SELECT COUNT * FROM ...". We
# support important integer operations.
class NewInt
  def >(other)
    # <-- logic to store current continuation (in a global queue)
    #    will go here -->
    # Return one of true or false.
    false
  end
  def <=(other)
    # Same as above. Current continuation must be stored first.
    # Then, we return one of true or false.
    false
  end
end

# Expression `a > b` is converted to `a.>(b)` in Ruby. Hence the
# following already works:
ni = NewInt.new
puts (ni > 3)
# Unfortunately, the following doesn't work:
# puts (3 > ni) # throws error!
# But, not a problem. We can edit Fixnum.
# Fixnum is the class of all numbers in Ruby. Ruby lets us
# 'open' the Fixnum, and redefine the operators.
class Fixnum
  def >(other)
    if other.is_a? NewInt
      other <= self
    else
      super
    end
  end
end
# Now, the following works:
puts (3 > ni)
# We meanwhile keep a log of all SQL operations. An inevitable
# "commit transaction" call follows. At that point, we take one
# of the stored continuations, and execute it, this time passing
# a different value (i.e., true instead of false).
