require "active_record"

class User < ActiveRecord::Base
end

module Database
  def setup_db
    ActiveRecord::Base.establish_connection(
      adapter: "sqlite3",
      database: ":memory:",
    )

    ActiveRecord::Base.connection.execute(
      <<~SQL
        CREATE TABLE users (
          id INTEGER NOT NULL PRIMARY KEY,
          access_token VARCHAR(255),
          refresh_token VARCHAR(255),
          expires_at INTEGER
        )
      SQL
    )
  end
end
