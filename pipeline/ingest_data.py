import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm
from typing import Iterator
import click

prefix = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/"

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64",
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime",
]

@click.command()
@click.option("--pg-user", default="root", help="Postgres user")
@click.option("--pg-password", default="root", help="Postgres password")
@click.option("--pg-host", default="pgdatabase", help="Postgres host")
@click.option("--pg-port", default=5432, type=int, help="Postgres port")
@click.option("--pg-db", default="ny_taxi", help="Postgres database")
@click.option("--year", default=2021, type=int, help="Year of the data file")
@click.option("--month", default=1, type=int, help="Month of the data file")
@click.option("--target-table", default="yellow_taxi_data", help="Target table name")
@click.option("--chunksize", default=100000, type=int, help="CSV read chunksize")
def run(
    pg_user: str,
    pg_password: str,
    pg_host: str,
    pg_port: int,
    pg_db: str,
    year: int,
    month: int,
    target_table: str,
    chunksize: int,
) -> None:
    engine = create_engine(
        f"postgresql+psycopg://{pg_user}:{pg_password}@{pg_host}:{pg_port}/{pg_db}"
    )

    url = f"{prefix}yellow_tripdata_{year}-{month:02d}.csv.gz"

    df_iter: Iterator[pd.DataFrame] = pd.read_csv(
        url,
        dtype=dtype,
        parse_dates=parse_dates,
        chunksize=chunksize,
    )

    first_chunk = next(df_iter)

    first_chunk.head(0).to_sql(
        name=target_table,
        con=engine,
        if_exists="replace",
        index=False,
    )

    print("Table created")

    first_chunk.to_sql(
        name=target_table,
        con=engine,
        if_exists="append",
        index=False,
    )

    print("Inserted first chunk:", len(first_chunk))

    for df_chunk in tqdm(df_iter):
        df_chunk.to_sql(
            name=target_table,
            con=engine,
            if_exists="append",
            index=False,
        )
        print("Inserted chunk:", len(df_chunk))

if __name__ == "__main__":
    run()