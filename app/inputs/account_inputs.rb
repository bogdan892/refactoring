module AccountInputs
  def account_form_data
    { name: input('user.name'), age: input('user.age').to_i, login: input('user.login'),
      password: input('user.password') }
  end

  def fill_account_form(action)
    loop do
      form = AccountForm.new(action, account_form_data)
      if form.valid?
        yield form
        break
      end
      puts form.errors
    end
  end
end
