require 'sinatra'
# require 'sinatra/reloader'
require 'rest-client'
require 'json'


set :bind, '0.0.0.0'
# #
# This is our only html view...
#
get '/' do
  if session[:user_id]
    # TODO: Grab user from database
    @user = Petshop::UsersRepo.find(db, session[:user_id])
    @current_user = user['name']

  end
  erb :index
end

# #
# ...the rest are JSON endpoints
#
get '/shops' do
  headers['Content-Type'] = 'application/json'
  RestClient.get("http://pet-shop.api.mks.io/shops")

end

get '/signup' do

  erb :"signup"
end
post '/signup' do
  db = PetShop.create_db_connection()
  password_hash = BCrypt::Password.create(params['password'])
  Petshop::UsersRepo.save db, {username: params['username'], password: password_hash}
  erb :"signup"
end
post '/signin' do
  params = JSON.parse request.body.read

  username = params['username']
  password = params['password']
  user = Petshop::UsersRepo.find_by_name(db, username)
  # TODO: Grab user by username from database and check password
  pass_from_db = BCrypt::Password.new(user['password'])

  if pass_from_db == password
    headers['Content-Type'] = 'application/json'
    session[:user_id] = user['id']
    # TODO: Return all pets adopted by this user
    pets = PetShop::UsersRepo.show_adoptions(db, user)
    # TODO: Set session[:user_id] so the server will remember this user has logged in

  else
    status 401
  end
end

 # # # #
# Cats #
# # # #
get '/shops/:id/cats' do
  headers['Content-Type'] = 'application/json'
  id = params[:id]
  # TODO: Grab from database instead
  RestClient.get("http://pet-shop.api.mks.io/shops/#{id}/cats")
end

put '/shops/:shop_id/cats/:id/adopt' do
  headers['Content-Type'] = 'application/json'
  shop_id = params[:shop_id]
  id = params[:id]
  # TODO: Grab from database instead
  RestClient.put("http://pet-shop.api.mks.io/shops/#{shop_id}/cats/#{id}",
    { adopted: true }, :content_type => 'application/json')
  # TODO (after you create users table): Attach new cat to logged in user
end


 # # # #
# Dogs #
# # # #
get '/shops/:id/dogs' do
  headers['Content-Type'] = 'application/json'
  db = PetShop.create_db_connection()
  id = params[:id]

  dogs = PetShop::DogsRepo.all_from_shop(db, id)
  JSON.generate(dogs)
  # TODO: Update database instead
  # RestClient.get("http://pet-shop.api.mks.io/shops/#{id}/dogs")
end

put '/shops/:shop_id/dogs/:id/adopt' do
  headers['Content-Type'] = 'application/json'
  shop_id = params[:shop_id]
  id = params[:id]
  db = PetShop.create_db_connection()
  # TODO: Update database instead
  Petshop::DogsRepo.adopt_dog(db, id)
  adopt_data = {
    type: 'dog',
    user_id: @user['id'],
    pet_id: id
    }
  Petshop::UsersRepo.adopt(db, adopt_data)
  # RestClient.put("http://pet-shop.api.mks.io/shops/#{shop_id}/dogs/#{id}",
  #   { adopted: true }, :content_type => 'application/json')
  # TODO (after you create users table): Attach new dog to logged in user
end


$sample_user = {
  id: 999,
  username: 'alice',
  cats: [
    { shopId: 1, name: "NaN Cat", imageUrl: "http://i.imgur.com/TOEskNX.jpg", adopted: true, id: 44 },
    { shopId: 8, name: "Meowzer", imageUrl: "http://www.randomkittengenerator.com/images/cats/rotator.php", id: 8, adopted: "true" }
  ],
  dogs: [
    { shopId: 1, name: "Leaf Pup", imageUrl: "http://i.imgur.com/kuSHji2.jpg", happiness: 2, id: 2, adopted: "true" }
  ]
}
