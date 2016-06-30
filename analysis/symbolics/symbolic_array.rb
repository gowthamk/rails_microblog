class SymbolicArray < SymbolicValue
  def initialize(name,sym_val,logger)
    super(name)
    @sym_value = sym_val
    @logger = logger
  end
  def map
    @logger.debug("#{@name}.map do |#{@sym_value.name}|")
    x = yield @sym_value
    @logger.debug("end")
    x
  end
end