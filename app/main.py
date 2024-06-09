from database import Database
from utils import get_db_uri
from sqlalchemy import text
from secrets import token_urlsafe

# Create the database connection
uri = get_db_uri() 

db = Database(uri)

# Insert data into the database
with db.engine.connect() as conn:
   select_query = text("SELECT * FROM tokens")
   result = conn.execute(select_query)
   data = result.fetchall()

print(data)

# Insert data into the database
with db.engine.begin() as conn:
   insert_query = text(f"INSERT INTO tokens (token) VALUES ('{token_urlsafe()}')")
   conn.execute(insert_query)

   select_query = text("SELECT * FROM tokens")
   result = conn.execute(select_query)
   data = result.fetchall()

print(data)