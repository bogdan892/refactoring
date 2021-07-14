class BaseTransactionResult
  attr_reader :errors

  def initialize(params)
    @card = params[:card]
    @amount = params[:amount]
    @errors = params[:errors]
  end

  def success?
    errors.empty?
  end

  def to_s
    errors.empty? ? success_message : errors.to_s
  end
end
