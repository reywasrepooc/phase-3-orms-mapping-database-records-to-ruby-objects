class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql =  "DROP TABLE IF EXISTS songs"

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO songs (name, album) VALUES (?, ?)"

    DB[:conn].execute(sql, name, album)

    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], album: row[2])
  end

  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL
    DB[:conn].execute(sql).map do |row|
      new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end
end
