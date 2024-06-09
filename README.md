# SQL Alchemy - minimum example

This is an example of how to use SQLAlchemy to connect to a PostgreSQL database. The example includes a database class that manages the connection and session, a model class that represents a table in the database, and a utility class that gets the database URI from environment variables. You can either use local or dockerized Postgres instance. 

## Preamble

1. Clone the repository with command run `git clone git@github.com:brunolnetto/sqlalchemy-docker.git`;

Make sure to install `postgresql-contrib` and `postgresql-client` for required postgres packages. 

```bash
apt install postgresql-contrib postgresql-client
```

2. Install the dependencies: setup a virtual environment and install the dependencies

```bash
pip install virtualenv
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Local Postgresql instance

Run main code with command `.venv/bin/python3 backend/app/main.py`. 

## Dockerized Postgresql instance

On the dockerized, you must first:

1. Host database instance with command run:
```bash
docker run --name db -e POSTGRES_PASSWORD=mypassword -e POSTGRES_USER=myuser -e POSTGRES_DBNAME=mydb -p 5433:5433 -d postgres
```

OR 

```bash
docker compose up -d
``` 

2. Obtain container ip with command run `docker inspect db | jq -r '.[0].NetworkSettings.Networks[].IPAddress'`;
3. Alter file `.env` with environment variables `POSTGRES_HOST` to container ip and `POSTGRES_PORT` as 5432 (the post on container network) by command run, below:

```bash
docker inspect db | jq -r '.[0].NetworkSettings.Networks[].IPAddress'
```

4. Run command `.venv/bin/python3 app/main.py`



