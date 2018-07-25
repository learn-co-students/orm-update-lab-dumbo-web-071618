require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql= <<-SQL
      CREATE TABLE students(id INTEGER PRIMARY KEY, name TEXT, grade TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql= <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql= <<-SQL
        INSERT INTO students(name, grade) VALUES(?, ?)
      SQL

      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT id FROM students ORDER BY id DESC LIMIT 1").flatten[0]
    end
  end

  def update
    sql= <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql= <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    Student.new(row[0], row[1], row[2])
  end
end
