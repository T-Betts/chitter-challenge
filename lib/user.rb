require_relative './database_connection_setup'
require 'bcrypt'

class User
  attr_reader :id, :email, :user_name, :name, :password

  def initialize(id, email, user_name, name, password)
    @id = id
    @email = email
    @user_name = user_name
    @name = name
    @password = password
  end

  def self.all
    result = DatabaseConnection.query("SELECT * FROM users")
    result.map { |user| User.new(user['id'], user['email'], user['user_name'], user['name'], user['password']) }
  end

  def self.create(options)
    password = BCrypt::Password.create(options[:password])
    result = DatabaseConnection.query("INSERT INTO users (email, user_name, name, password) VALUES('#{options[:email]}', '#{options[:user_name]}', '#{options[:name]}', '#{password}') RETURNING id, email, user_name, name;")
    User.new(result[0]['id'], result[0]['email'], result[0]['user_name'], result[0]['name'], result[0]['password'])
  end

  def self.find(id)
    return nil unless id
    result = DatabaseConnection.query("SELECT * FROM users WHERE id = '#{id}'")
    User.new(result[0]['id'], result[0]['email'], result[0]['user_name'], result[0]['name'], result[0]['password'])
  end

  def self.authenticate(email, password)
    result = DatabaseConnection.query("SELECT * FROM users WHERE email = '#{email}'")
    return unless result.any?
    return unless BCrypt::Password.new(result[0]['password']) == password
    user = User.new(result[0]['id'], result[0]['email'], result[0]['user_name'], result[0]['name'], result[0]['password'])
  end
end
