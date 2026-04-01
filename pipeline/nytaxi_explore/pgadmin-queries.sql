--select count(*) as counter from public.yellow_taxi_data;

--select * from public.yellow_taxi_data limit 10;ﬁ
--select * from zones;

--informacao 
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'yellow_taxi_data';



SELECT column_name
FROM information_schema.columns
WHERE table_name = 'zones';

SELECT
    t.*,

    zpu."Borough"      AS pickup_borough,
    zpu."Zone"         AS pickup_zone,
    zpu."service_zone" AS pickup_service_zone,

    zdo."Borough"      AS dropoff_borough,
    zdo."Zone"         AS dropoff_zone,
    zdo."service_zone" AS dropoff_service_zone

FROM yellow_taxi_data t
LEFT JOIN zones zpu
    ON t."PULocationID" = zpu."LocationID"
LEFT JOIN zones zdo
    ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;




--Checar sem criterio/filtro
SELECT * 
FROM 
	yellow_taxi_data t,
	zones zpu,
	zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT 100;
	


-- Criando uma versao de tabela apenas com oque queremos ver
SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_loc",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_loc"
FROM 
	yellow_taxi_data t,
	zones zpu,
	zones zdo
WHERE 
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT 100;
	

-- Criando uma versao de tabela com JOIN's
SELECT 
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
	CONCAT(zpu."Borough", ' / ', zpu."Zone") AS "pick_up_loc",
	CONCAT(zdo."Borough", ' / ', zdo."Zone") AS "drop_off_loc"
FROM yellow_taxi_data t
LEFT JOIN zones zpu --
    ON t."PULocationID" = zpu."LocationID"
LEFT JOIN zones zdo
    ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- Checando se ha nulos
SELECT 
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_data
WHERE 
	"DOLocationID" is NULL
LIMIT 100;


-- Checando se ha orfaos
SELECT 
	"PULocationID",
	"DOLocationID"
FROM 
	yellow_taxi_data
WHERE 
	"PULocationID" NOT IN (SELECT "LocationID" from zones)
LIMIT 100;





-- Casting (conversao de data e resumo de quantas corridas por dia)
SELECT
	CAST(tpep_dropoff_datetime AS DATE) as "day",
	COUNT(*) as rides, 
	MAX(total_amount) AS revenue,
	MAX(passenger_count) AS passengers
FROM 
	yellow_taxi_data t
GROUP BY 
	CAST(tpep_dropoff_datetime AS DATE)
ORDER BY 
	rides DESC;



-- GROUPBY por 2 criterios
SELECT
	CAST(tpep_dropoff_datetime AS DATE) as "day",
	"DOLocationID",
	COUNT(*) as rides, 
	MAX(total_amount) AS revenue,
	MAX(passenger_count) AS passengers
FROM 
	yellow_taxi_data t
GROUP BY 
	1, 2 
ORDER BY 
	"day" ASC, 
	"DOLocationID" ASC;
	
	



--CREATE TABLE yellow_taxi_data_enriched AS
--SELECT
--    t.*,
--
--    zpu."Borough"      AS pickup_borough,
--    zpu."Zone"         AS pickup_zone,
--    zpu."service_zone" AS pickup_service_zone,
--
--    zdo."Borough"      AS dropoff_borough,
--    zdo."Zone"         AS dropoff_zone,
--    zdo."service_zone" AS dropoff_service_zone
--
--FROM yellow_taxi_data t
--LEFT JOIN zones zpu
--    ON t."PULocationID" = zpu."LocationID"
--LEFT JOIN zones zdo
--    ON t."DOLocationID" = zdo."LocationID";