install.packages('httr')
library('httr')
# URL for Current Weather API
current_weather_url <- 'https://api.openweathermap.org/data/2.5/weather'

# need to be replaced by your real API key
your_api_key <- "d4c3dbe327ffcdd434ee04dea7db63d1"
# Input `q` is the city name
# Input `appid` is your API KEY, 
# Input `units` are preferred units such as Metric or Imperial
current_query <- list(q = "Seoul", appid = your_api_key, units="metric")

response <- GET(current_weather_url, query=current_query)

http_type(response)

json_result <- content(response, as="parsed")
class(json_result)
json_result

# Create some empty vectors to hold data temporarily
weather <- c()
visibility <- c()
temp <- c()
temp_min <- c()
temp_max <- c()
pressure <- c()
humidity <- c()
wind_speed <- c()
wind_deg <- c()

# $weather is also a list with one element, its $main element indicates the weather status such as clear or rain
weather <- c(weather, json_result$weather[[1]]$main)
# Get Visibility
visibility <- c(visibility, json_result$visibility)
# Get current temperature 
temp <- c(temp, json_result$main$temp)
# Get min temperature 
temp_min <- c(temp_min, json_result$main$temp_min)
# Get max temperature 
temp_max <- c(temp_max, json_result$main$temp_max)
# Get pressure
pressure <- c(pressure, json_result$main$pressure)
# Get humidity
humidity <- c(humidity, json_result$main$humidity)
# Get wind speed
wind_speed <- c(wind_speed, json_result$wind$speed)
# Get wind direction
wind_deg <- c(wind_deg, json_result$wind$deg)

# Combine all vectors
weather_data_frame <- data.frame(weather=weather, 
                                 visibility=visibility, 
                                 temp=temp, 
                                 temp_min=temp_min, 
                                 temp_max=temp_max, 
                                 pressure=pressure, 
                                 humidity=humidity, 
                                 wind_speed=wind_speed, 
                                 wind_deg=wind_deg)

# Check the generated data frame
print(weather_data_frame)

# City name column
city <- c()
# Weather column, rainy or cloudy, etc
weather <- c()
# Sky visibility column
visibility <- c()
# Current temperature column
temp <- c()
# Max temperature column
temp_min <- c()
# Min temperature column
temp_max <- c()
# Pressure column
pressure <- c()
# Humidity column
humidity <- c()
# Wind speed column
wind_speed <- c()
# Wind direction column
wind_deg <- c()
# Forecast timestamp
forecast_datetime <- c()
# Season column
# Note that for season, you can hard code a season value from levels Spring, Summer, Autumn, and Winter based on your current month.
season <- c()

# Get forecast data for a given city list
get_weather_forecaset_by_cities <- function(city_names){
    df <- data.frame()
    for (city_name in city_names){
        # Forecast API URL
        forecast_url <- 'https://api.openweathermap.org/data/2.5/forecast'
        # Create query parameters
        forecast_query <- list(q = city_name, appid = your_api_key, units="metric")
        # Make HTTP GET call for the given city
        response <- GET(forecast_url, query = forecast_query)
        # Note that the 5-day forecast JSON result is a list of lists. You can print the reponse to check the results
        json_list <- content(response, as = "parsed")
        results <- json_list$list
        # Loop the json result
        for(result in results) {
            city <- c(city, city_name)
            weather <- c(weather, result$weather[[1]]$main)
            visibility <- c(visibility, result$visibility)
            temp <- c(temp, result$main$temp)
            temp_min <- c(temp_min, result$main$temp_min)
            temp_max <- c(temp_max, result$main$temp_max)
            pressure <- c(pressure, result$main$pressure)
            humidity <- c(humidity, result$main$humidity)
            wind_speed <- c(wind_speed, result$wind$speed)
            wind_deg <- c(wind_deg, result$wind$deg)
            forecast_datetime <- c(forecast_datetime, result$dt_txt)
        }
        new_row <- data.frame(city = city,
                              weather = weather,
                             visibility = visibility,
                             temp=temp,
                             temp_min-temp_min,
                             temp_max=temp_max,
                             pressure=pressure,
                             humidity=humidity,
                             wind_speed=wind_speed,
                             wind_deg=wind_deg,
                             forecast_datetime=forecast_datetime,
                             season="Spring")
        df <- rbind(df, new_row)
        # Add the R Lists into a data frame
    }
    
    # Return a data frame
    return(df)
    
}
forecast_url <- 'https://api.openweathermap.org/data/2.5/forecast'
forecast_query <- list(q = "Seoul", appid = your_api_key, units="metric")
response <- GET(forecast_url, query = forecast_query)
json_list <- content(response, as = "parsed")
json_list

cities <- c("Seoul", "Washington, D.C.", "Paris", "Suzhou")
cities_weather_df <- get_weather_forecaset_by_cities(cities)

# Write cities_weather_df to `cities_weather_forecast.csv`
write.csv(cities_weather_df, "cities_weather_forecast.csv", row.names=FALSE)
