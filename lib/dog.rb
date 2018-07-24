require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    dog = Dog.new(name:row[1],breed:row[2],id:row[0])
    dog
  end

  def self.find_by_name(name)
   sql = <<-SQL
    SELECT * FROM dogs WHERE dogs.name = ?
      SQL
    DB[:conn].execute(sql,name).collect do |row|

    new_from_db(row)
  end.first
end



  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs(name,breed) Values(?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
 end

  def update
    sql = <<-SQL
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
     SQL

     DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

def self.create(name:, breed:)
dog = Dog.new(name: name,breed: breed)
dog.save

end

def self.find_by_id(id)
  sql = <<-SQL
  SELECT * FROM dogs WHERE dogs.id = ?
  SQL

  dog = DB[:conn].execute(sql, id)[0]

  Dog.new(name:dog[1],breed:dog[2],id:dog[0])
end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

      dog = DB[:conn].execute(sql,name,breed)

      if dog.empty?
      create(name:name,breed:breed)
      else
        dog_= new_from_db(dog[0])
        dog_.id = dog[0][0]

        end
        dog_
      end

end
