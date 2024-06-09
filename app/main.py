from .database import Database
from utils import get_db_uri
from sqlalchemy import text

# Create the database connection
uri = get_db_uri() 
print(uri)

db = Database(uri)

# Insert data into the database
with db.engine.connect() as conn:
    query = text("INSERT INTO tokens (token) VALUES ('mytoken')")
    conn.execute(query)

