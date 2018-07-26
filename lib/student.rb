require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :id
  attr_reader :grade

  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if id.nil?
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      sql = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql)[0][0]
    else
      self.update
    end
  end

  def self.create(name, grade)
    (self.new(name, grade)).save
  end

  def self.new_from_db(row)
    new_inst = self.new(row[1], row[2])
    new_inst.id = row[0]
    new_inst
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
