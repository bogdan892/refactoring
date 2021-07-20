class ValidableEntity
  def errors
    @errors ||= ValidationErrors.new
  end

  def valid?
    validate
    errors.empty?
  end
end
