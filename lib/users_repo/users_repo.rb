module Petshop
  class UsersRepo
    # find a user by user ID. Intended to be used when
    # someone is already authenticated. We keep their
    # user id in the cookie.
    def self.find db, user_id
      sql = %q[SELECT * FROM users WHERE id = $1]
      result = db.exec(sql, [user_id])
      result.first
    end

    # find user by username. Intended to be used when
    # someone tries to sign in.
    def self.find_by_name db, username
      sql = %q[SELECT * FROM users WHERE username = $1]
      result = db.exec(sql, [username])
      result.first
    end

    # when someone signs up use this method to save their
    # information in the db. we're not encrypting passwords.
    def self.save db, user_data
      sql = %q[INSERT INTO users (username, password) VALUES ($1, $2) RETURNING *]
      result = db.exec(sql, [user_data[:username], user_data[:password]])
      result.first
    end
    def self.adopt db, user_data
      sql = <<-SQL
        INSERT INTO pet_adptions (type, user_id, pet_id) 
        VALUES ($1, $2, $3) RETURNING * SQL
      result = db.exec(sql, user_data[:type]], [user_data[:id], user_data[:pet_id]])
      if(user_data[:type] == "cat")
        PetShop::CatsRepo.adopt(user_data[:pet_id])
      end
      if(user_data[:type] == "dog")
        PetShop::DogsRepo.adopt(user_data[:pet_id])
      end
      result.first
    end
    def self.show_adoptions db, user_data
      sql = <<-SQL SELECT u.id, u.name, a.name
        FROM pet_adptions p
        JOIN users u ON p.user_id = u.id
        JOIN cats a ON p.cat_id = a.id
        WHERE p.type = 'cat' and u.id = $1 

        SQL
      result = db.exec(sql, [user_data[:id]])
      result.first
    end
  end
end
