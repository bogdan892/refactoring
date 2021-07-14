class ValidationErrors
  extend Forwardable
  extend Enumerable

  def_delegators :@errors, :each, :empty?, :<<

  def initialize(errors = [])
    @errors = errors
  end

  def to_s
    @errors.join
  end
end
