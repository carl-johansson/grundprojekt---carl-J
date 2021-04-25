require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'

enable :sessions



before do
  session["password"] = "abc123"
  session["user"] = "John Smith"
  #session.destroy
end

# Startsida
get('/notes/start') do # ('/')
  slim(:index)
end

#Visa formulär som lägger till en note
get('/notes/new') do
  slim(:"notes/new")
end






#settings
get('/notes/settings') do
  slim(:'/notes/settings')
end

#Visa alla notes
get('/notes') do
  slim(:"notes/show")
end

get('/start') do
  slim(:'/notes/start') #/notes/start    senare 'index'
end

get('/wrong_reg') do
  slim(:'/wrong_register')
end

get('/wrong_log') do
  slim(:'/wrong_login')
end



#Dags för ändra username

post("/notes/settings") do
  username = params[:new_username]
  username_confirm = params[:username_confirm]

  if (new_username == username_confirm)
  sessions[:new_username] = username
  redirect('/wrong_reg')
  else
    "The usernames don't match"
  end
  # sessions.update
end



#Mitt prpr:ande




#Nya användare
get('/') do
  slim(:register)
end
post("/users/new") do #/user/new
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
    #lägg till användaren
    password_digest = BCrypt::Password.create(password) #spelar ingen roll om det är password eller password_confirm då de e samma
    db = SQLite3::Database.new('db/filnamn.db')
    db.results_as_hash = true
    db.execute("INSERT INTO users (username, pwdigest) VALUES (?, ?)", username, password_digest) #första ? = username, andra ? = username_digest
    session[:username] = username
    redirect('/notes/start') #redirect till rotmappen, geten (get)
## /notes/start
  else
    #felhantering
    redirect('/wrong_reg')
  end
end

# get('/') do
#   slim(:login)
# end
#Gammal användare
post("/user/old") do  #login
  username = params[:username]
  password = params[:password]

  db = SQLite3::Database.new('db/filnamn.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?", username).first #första ? = username
  session[:username] = username
  pwdigest = result["pwdigest"]
  id = result["id"]
  if BCrypt::Password.new(pwdigest) == password
    redirect('/notes/start') #ändrar från todos
  else ## /notes/start
    redirect('/wrong_log')
    "Wrong password"
  end

  redirect('/notes/start') #redirect till rotmappen, geten (get)
  ## /notes/start
end

#lägger till text för att se om github funkar
#lägger till ny hashtag för att se om github funkar

#Under denna lektionen fredag 23 apr har jag fixat github.
#Ändrat från svenska till engelska på tex submit knappar, ska göra allt på engelska (enklare så)
#Fixade notes, rubrik finns samt vem som skrev den (den som är inne i session atm)

#22 apr lyckades jag lägga till settings, nu behöver jag fixa så att ändra användarnamnet där innebär att man ändrar i databasen men behåller lösenordet.


#Utveckla note-formuläret, spara tex även rubrik för note och författare


#Skapa note
post('/notes/create') do
  if session["notes"] == nil
    session["notes"] = []
    session["notes"] << params["ny_rubrik"] + ", " + params["ny_note"] + "  " + "- Note skriven av: #{session[:username]}"
  else
    session["notes"] << params["ny_rubrik"] + ", " + params["ny_note"] + "  " + "- Note skriven av: #{session[:username]}"
  end
  redirect('/notes')
end

#Ta bort notes
post('/notes/show') do
  if session["notes"] == nil
    session["notes"] = []
  else
    session["notes"].destroy = destroy
  end
  redirect('/notes')
end


#skapa note
post('/notes/create') do
  rubrik = params[:rubtik]
  note_id = params[:note_id].to_i
  p "vi fick in datan #{title} och #{note_id}"
  db = SQLite3::Database.new("db/filnamn.db") #stoppa in datan
  db.execute("INSERT INTO notes (Rubrik, NoteId) VALUES (?, ?)", rubrik, note_id)
  redirect('/notes')
end

post('/notes/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/filnamn.db") #stoppa in datan
  db.execute("DELETE FROM notes WHERE NoteId = ?", id)
  redirect('/notes')
end