class AccountForm < ValidableEntity
  MIN_LOGIN_LENGTH = 4
  MAX_LOGIN_LENGTH = 20
  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 30
  AGE = (23..90).freeze

  def initialize(action, data)
    super()
    @action = action
    @login = data[:login]
    @password = data[:password]
    @name = data[:name]
    @age = data[:age]
  end

  def create_account
    @action.create_account(name: @name, age: @age, login: @login, password: @password)
  end

  private

  def validate
    validate_name
    validate_age
    validate_login
    validate_accounts_exists
    validate_password
  end

  def account_exists?
    @action.account_exists?(@login)
  end

  def login_short?
    @login.length < MIN_LOGIN_LENGTH
  end

  def login_long?
    @login.length > MAX_LOGIN_LENGTH
  end

  def password_short?
    @password.length < MIN_PASSWORD_LENGTH
  end

  def password_long?
    @password.length > MAX_PASSWORD_LENGTH
  end

  def age_invalid?
    !AGE.member?(@age)
  end

  def name_invalid?
    @name.empty? || @name[0].upcase != @name[0]
  end

  def validate_name
    errors << I18n.t('account_validation.name.first_letter') if name_invalid?
  end

  def validate_age
    errors << I18n.t('account_validation.age.length', min: AGE.min, max: AGE.max) if age_invalid?
  end

  def validate_login
    errors << I18n.t('account_validation.login.present') if @login.empty?
    errors << I18n.t('account_validation.login.longer', min: MIN_LOGIN_LENGTH) if login_short?
    errors << I18n.t('account_validation.login.shorter', max: MAX_LOGIN_LENGTH) if login_long?
  end

  def validate_password
    errors << I18n.t('account_validation.password.present') if @password.empty?
    errors << I18n.t('account_validation.password.longer', min: MIN_PASSWORD_LENGTH) if password_short?
    errors << I18n.t('account_validation.password.shorter', max: MAX_PASSWORD_LENGTH) if password_long?
  end

  def validate_accounts_exists
    errors << I18n.t('account_validation.login.exists') if account_exists?
  end
end
