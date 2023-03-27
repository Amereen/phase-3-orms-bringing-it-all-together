class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(args = {})
    @id = args[:id]
    @name = args[:name]
    @breed = args[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table 
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(name:,breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = self.new(id: id, name: name, breed: breed)
    new_dog
  end 

  def self.all
    sql = "SELECT * FROM dogs"
    rows = DB[:conn].execute(sql)
    rows.map { |row| self.new_from_db(row) }
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name).first
    if row
      self.new_from_db(row)
    else
      nil
    end
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    row = DB[:conn].execute(sql, id).first

    if row
      self.new_from_db(row)
    else
      nil
    end
  end
end
