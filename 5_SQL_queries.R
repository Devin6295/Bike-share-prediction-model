#install.packages("https://cran.r-project.org/src/contrib/Archive/RSQLite/RSQLite_0.10.0.tar.gz", repos = NULL, type = "source", dependencies = TRUE) 

library("RSQLite")

getwd()

# provide your solution here to connect db
conn <- dbConnect(RSQLite::SQLite(), "FinalDB.sqlite")

worldcities <- read.csv("/resources/RP0321EN/labs/FinalRSQLite/world_cities.csv")
df1 <- dbExecute(conn, 
                 "CREATE TABLE WORLD_CITIES (
                                      CITY VARCHAR(20) NOT NULL,
                                      CITY_ASCII VARCHAR(20) NOT NULL,
                                      LAT FLOAT(8) NOT NULL,
                                      LNG FLOAT(8) NOT NULL, 
                                      COUNTRY VARCHAR(20) NOT NULL,
                                      ISO2 VARCHAR(20) NOT NULL,
                                      ISO3 VARCHAR(20) NOT NULL,
                                      ADMIN_NAME VARCHAR(20) NOT NULL,
                                      CAPITAL VARCHAR(20),
                                      POPULATION INTEGER,
                                      ID INTEGER,
                                      PRIMARY KEY (ID)
                                      )")
dbWriteTable(conn, "WORLD_CITIES", worldcities, overwrite=TRUE, header = TRUE)

bikeshare <- read.csv("/resources/RP0321EN/labs/FinalRSQLite/bike_sharing_systems.csv")
df2 <- dbExecute(conn, 
                 "CREATE TABLE BIKE_SHARING_SYSTEMS (
                                      COUNTRY VARCHAR(20) NOT NULL,
                                      CITY VARCHAR(20) NOT NULL,
                                      SYSTEM VARCHAR(20) NOT NULL,
                                      BICYCLES INTEGER NOT NULL,
                                      PRIMARY KEY (COUNTRY)
                                      )")
dbWriteTable(conn, "BIKE_SHARING_SYSTEMS", bikeshare, overwrite=TRUE, header = TRUE)

weather <- read.csv("/resources/RP0321EN/labs/FinalRSQLite/cities_weather_forecast.csv")
df3 <- dbExecute(conn, 
                 "CREATE TABLE CITIES_WEATHER_FORECAST (
                                      CITY VARCHAR(20) NOT NULL,
                                      WEATHER VARCHAR(20) NOT NULL,
                                      VISIBILITY INTEGER NOT NULL,
                                      TEMP FLOAT(8) NOT NULL,
                                      TEMP_MIN FLOAT(8) NOT NULL,
                                      TEMP_MAX FLOAT(8) NOT NULL,
                                      PRESSURE INTEGER NOT NULL,
                                      HUMIDITY INTEGER NOT NULL,
                                      WIND_SPEED FLOAT(8) NOT NULL,
                                      WIND_DEG INTEGER NOT NULL,
                                      SEASON VARCHAR(20) NOT NULL,
                                      FORECAST_DATETIME DATE NOT NULL,
                                      PRIMARY KEY (CITY)
                                      )")
dbWriteTable(conn, "CITIES_WEATHER_FORECAST", weather, overwrite=TRUE, header = TRUE)

seoulbikes <- read.csv("/resources/RP0321EN/labs/FinalRSQLite/seoul_bike_sharing.csv")
df4 <- dbExecute(conn, 
                 "CREATE TABLE SEOUL_BIKE_SHARING (
                                      DATE DATE NOT NULL,
                                      RENTED_BIKE_COUNT INTEGER NOT NULL,
                                      HOUR INTEGER NOT NULL,
                                      TEMPERATURE FLOAT(8) NOT NULL,
                                      HUMIDITY INTEGER NOT NULL,
                                      WIND_SPEED FLOAT(8) NOT NULL,
                                      VISIBILITY INTEGER NOT NULL,
                                      DEW_POINT_TEMPERATURE FLOAT(8) NOT NULL,
                                      SOLAR_RADIATION FLOAT(8) NOT NULL,
                                      RAINFALL FLOAT(8) NOT NULL,
                                      SNOWFALL FLOAT(8) NOT NULL,
                                      SEASONS VARCHAR(20) NOT NULL,
                                      HOLIDAY VARCHAR(20) NOT NULL,
                                      FUNCTIONING_DAY VARCHAR(20) NOT NULL,
                                      PRIMARY KEY (DATE)
                                      )")
dbWriteTable(conn, "SEOUL_BIKE_SHARING", seoulbikes, overwrite=TRUE, header = TRUE)

# Find number of records
dbGetQuery(conn, "SELECT COUNT(*) FROM SEOUL_BIKE_SHARING")

#How many hours had a non-zero count
dbGetQuery(conn, "SELECT SUM(RENTED_BIKE_COUNT) AS TOTAL_HOURS FROM SEOUL_BIKE_SHARING WHERE RENTED_BIKE_COUNT <> 0")

# weather forcast for next 3 hours
dbGetQuery(conn, "SELECT * FROM CITIES_WEATHER_FORECAST WHERE CITY == 'Seoul' AND FORECAST_DATETIME >= 2021-04-20 ORDER BY FORECAST_DATETIME ASC LIMIT 1")

# find all four seasons in database
dbGetQuery(conn, "SELECT DISTINCT(SEASONS) AS SEASONS FROM SEOUL_BIKE_SHARING")

#find datarange
dbGetQuery(conn, "SELECT MAX(DATE) AS LAST_DATE, MIN(DATE) AS FIRST_DATE FROM SEOUL_BIKE_SHARING")

# find all time high
dbGetQuery(conn, "SELECT DATE, HOUR FROM SEOUL_BIKE_SHARING WHERE RENTED_BIKE_COUNT == (SELECT MAX(RENTED_BIKE_COUNT) FROM SEOUL_BIKE_SHARING)")

# find hourly popularity and temperature by season
dbGetQuery(conn, "SELECT AVG(TEMPERATURE) AS AVG_TEMP, AVG(RENTED_BIKE_COUNT) AS AVG_BIKE_RENTALS, HOUR, SEASONS FROM SEOUL_BIKE_SHARING GROUP BY HOUR, SEASONS ORDER BY AVG_BIKE_RENTALS DESC LIMIT 10")

# find average hourly bike count by season
dbGetQuery(conn, "SELECT SEASONS, AVG(RENTED_BIKE_COUNT) AS AVG_BIKE_RENTALS, MAX(RENTED_BIKE_COUNT) AS MAX_BIKE_RENTALS, MIN(RENTED_BIKE_COUNT) AS MIN_BIKE_RENTALS, SQRT(AVG(RENTED_BIKE_COUNT*RENTED_BIKE_COUNT)-AVG(RENTED_BIKE_COUNT)*AVG(RENTED_BIKE_COUNT)) AS STD_BIKE_RENTALS
                    FROM SEOUL_BIKE_SHARING
                    GROUP BY SEASONS")

#Find average weather by season
dbGetQuery(conn, "SELECT SEASONS,
AVG(TEMPERATURE) AS AVG_TEMP,
AVG(HUMIDITY) AS AVG_HUM,
AVG(WIND_SPEED) AS AVG_WINDSPEED,
AVG(VISIBILITY) AS AVG_VIS, 
AVG(DEW_POINT_TEMPERATURE) AS AVG_DEW_POINT_TEMP,
AVG(SOLAR_RADIATION) AS AVG_SOLAR_RAD,
AVG(RAINFALL) AS AVG_RAIN,
AVG(SNOWFALL) AS AVG_SNOW,
AVG(RENTED_BIKE_COUNT) AS AVG_RENTALS
FROM SEOUL_BIKE_SHARING
GROUP BY SEASONS
ORDER BY AVG_RENTALS DESC")

#total bike count and city info for Seoul
dbGetQuery(conn, "SELECT SUM(BICYCLES) AS TOTAL_BIKES, WORLD_CITIES.CITY, WORLD_CITIES.COUNTRY, LAT, LNG, POPULATION
           FROM WORLD_CITIES, BIKE_SHARING_SYSTEMS 
           WHERE WORLD_CITIES.CITY = BIKE_SHARING_SYSTEMS.CITY AND WORLD_CITIES.CITY=='Seoul'")

#Find comparable cities to Seoul
dbGetQuery(conn, "SELECT SUM(BIKE_SHARING_SYSTEMS.BICYCLES) AS TOTAL_BIKES, WORLD_CITIES.CITY, WORLD_CITIES.COUNTRY, LAT, LNG, POPULATION
           FROM WORLD_CITIES, BIKE_SHARING_SYSTEMS 
           WHERE WORLD_CITIES.CITY = BIKE_SHARING_SYSTEMS.CITY
GROUP BY WORLD_CITIES.CITY
HAVING TOTAL_BIKES <= 20000 AND TOTAL_BIKES >= 15000")

close(conn)