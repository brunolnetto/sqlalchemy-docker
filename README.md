# SQL Alchemy - minimum example

This is an example of how to use SQLAlchemy to connect to a PostgreSQL database. The example includes a database class that manages the connection and session, a model class that represents a table in the database, and a utility class that gets the database URI from environment variables.

## Reproduction

1. Clone the repository

```bash
git clone git@github.com:brunolnetto/sql-alchemy-mvp.git
```

2. Install the dependencies: setup a virtual environment and install the dependencies

```bash
pip install virtualenv
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. Host docker container with PostgreSQL:

```bash
docker run --name db -e POSTGRES_PASSWORD=mypassword -e POSTGRES_USER=myuser -e POSTGRES_DBNAME=mydb -p 5433:5433 -d postgres
```

OR 

```bash
docker-compose up -d
```

4. Run the application

```bash
.venv/bin/python app/main.py
```

# Content

## app/main.py

```python
from database import Database
from utils import get_db_uri
from sqlalchemy import text

# Create the database connection
uri = get_db_uri() 

db = Database(uri)

# Insert data into the database
with db.engine.connect() as conn:
    query = text("INSERT INTO tokens (token) VALUES ('mytoken')")
    conn.execute(query)
```

## database.py

```python
from psycopg2 import OperationalError
from sqlalchemy import create_engine
from sqlalchemy import create_engine, pool
from sqlalchemy import text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.engine.url import URL
from sqlalchemy_utils import database_exists, create_database

from models import Base
from utils import get_db_uri

class Database:
    """
    This class represents a database connection and session management object.
    It contains two attributes:
    
    - engine: A callable that represents the database engine.
    - session_maker: A callable that represents the session maker.
    """
    def __init__(self, uri: URL):
        self.uri = uri
    
        self.engine = create_engine(
            uri,
            poolclass=pool.QueuePool,   # Use connection pooling
            pool_size=20,               # Adjust pool size based on your workload
            max_overflow=10,            # Adjust maximum overflow connections
            pool_recycle=3600           # Periodically recycle connections (optional)
        )

        self.session_maker = sessionmaker(
            autocommit=False, 
            autoflush=False, 
            bind=self.engine
        )

        self.create_database()
        self.test_connection()
        self.init()

    def test_connection(self):
        """

        Tests the connection to the database.

        Raises:
            Exception: If there's an error connecting to the database.
        """

        # Test the connection
        try:
            with self.engine.connect() as conn:
                query = text("SELECT 1")

                # Test the connection
                conn.execute(query)

                print('Connection to the database established!')
        
        except Exception as e:
            raise Exception(f"Error connecting to database: {e}")

    def create_database(self):
        """
        Attempts to create the database if it doesn't exist.

        Args:
            engine: The SQLAlchemy engine object.
            settings: A dictionary containing database connection details.

        Raises:
            DatabaseError: If there's an error checking or creating the database.
        """
        # Get the database URI
        db_uri = get_db_uri()
        
        # Create the database if it does not exist
        if not database_exists(db_uri): 
            create_database(db_uri)


    def init(self):
        """
        Connects to a PostgreSQL database using environment variables for connection details.
    
        Returns:
            Database: A class with engine and conn attributes for the database connection.
            None: If there was an error connecting to the database.
    
        """
        try:
            # Create all tables defined using the Base class
            Base.metadata.create_all(self.engine)
            print('Tables created successfully!')        
        
        except OperationalError as e:
            raise Exception(f"Error connecting to database: {e}")
            return None
    
    def __repr__(self) -> str:
        return f"Database(uri={self.uri})" 
```

## models.py

```python
from sqlalchemy import (
  Column, Integer, String
)
from typing import Generic, TypeVar
from pydantic import BaseModel, Field

from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

T = TypeVar('T')

class TokensDBSchema(BaseModel, Generic[T]):
    id: int = Field(..., description="Unique identifier for the user.")
    token: str = Field(..., description="Token for the user.")

class TokensDB(Base):
    """
    SQLAlchemy model for the user table.
    """
    __tablename__ = 'tokens'
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    token = Column(String, nullable=False)

    def __get_pydantic_core_schema__(self):
        return TokensDBSchema(id=self.id, token=self.token) 
```

## utils.py

```python
from os import getenv, path, getcwd
from dotenv import load_dotenv

def get_connection_dict():
    env_path = path.join(getcwd(), '.env')
    load_dotenv(env_path)
    
    # Get the host
    host = getenv('POSTGRES_HOST', 'localhost')

    # Get environment variables
    port = int(getenv('POSTGRES_PORT', '5433'))

    # Get the user and password
    user = getenv('POSTGRES_USER', 'postgres')
    passw = getenv('POSTGRES_PASSWORD', 'postgres')
    database_name = getenv('POSTGRES_DBNAME')

    return dict(
        host=host,
        port=port,
        user=user,
        password=passw,
        database_name=database_name
    )

def get_db_uri(has_dbname=True):
    """
    Build the database URI based on the environment variables.

    Returns:
        str: The database URI.
    """
    conn_dict=get_connection_dict()
    
    # Connect to the database
    dsn_str='postgresql'
    credentials=f"{conn_dict['user']}:{conn_dict['password']}"
    route=f"{conn_dict['host']}:{conn_dict['port']}"
    db_name=conn_dict['database_name']
    
    if has_dbname:
        return f"{dsn_str}://{credentials}@{route}/{db_name}"
    else:
        return f"{dsn_str}://{credentials}@{route}"
```
