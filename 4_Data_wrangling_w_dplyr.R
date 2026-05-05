library(tidyverse)

bike_sharing_df <- read_csv("raw_seoul_bike_sharing.csv")

summary(bike_sharing_df)
dim(bike_sharing_df)

# Drop rows with `RENTED_BIKE_COUNT` column == NA
bike_sharing_df <- bike_sharing_df %>% drop_na(RENTED_BIKE_COUNT)

# Print the dataset dimension again after those rows are dropped
dim(bike_sharing_df)

bike_sharing_df %>% 
  filter(is.na(TEMPERATURE))

# Calculate the summer average temperature
mean_temp <- mean(bike_sharing_df$TEMPERATURE)

# Impute missing values for TEMPERATURE column with summer average temperature
bike_sharing_df %>% replace_na(list(TEMPERATURE = mean_temp))
bike_sharing_df <- bike_sharing_df %>%
  
# Print the summary of the dataset again to make sure no missing values in all columns
summary(bike_sharing_df)

# Save the dataset as `seoul_bike_sharing.csv`
write_csv(bike_sharing_df, "seoul_bike_sharing.csv")

# Using mutate() function to convert HOUR column into character type
bike_sharing_df <- bike_sharing_df %>% mutate(HOUR = as.character(HOUR))

# Convert SEASONS, HOLIDAY, FUNCTIONING_DAY, and HOUR columns into indicator columns.
bike_sharing_df <- bike_sharing_df %>% 
  mutate(dummy = 1) %>%
  spread(
    key = SEASONS,
    value = dummy,
    fill = 0)

bike_sharing_df <- bike_sharing_df %>% 
  mutate(dummy = 1) %>%
  spread(
    key = HOLIDAY,
    value = dummy,
    fill = 0)

bike_sharing_df <- bike_sharing_df %>% 
  mutate(dummy = 1) %>%
  spread(
    key = FUNCTIONING_DAY,
    value = dummy,
    fill = 0)

bike_sharing_df <- bike_sharing_df %>% 
  mutate(dummy = 1) %>%
  spread(
    key = HOUR,
    value = dummy,
    fill = 0)

# Print the dataset summary again to make sure the indicator columns are created properly
head(bike_sharing_df)

# Save the dataset as `seoul_bike_sharing_converted.csv`
write_csv(bike_sharing_df, "seoul_bike_sharing_converted.csv")

# Use the `mutate()` function to apply min-max normalization on columns 
# `RENTED_BIKE_COUNT`, `TEMPERATURE`, `HUMIDITY`, `WIND_SPEED`, `VISIBILITY`, `DEW_POINT_TEMPERATURE`, `SOLAR_RADIATION`, `RAINFALL`, `SNOWFALL`
cols = c("RENTED_BIKE_COUNT",
         "TEMPERATURE",
         "HUMIDITY",
         "WIND_SPEED",
         "VISIBILITY",
         "DEW_POINT_TEMPERATURE",
         "SOLAR_RADIATION",
         "RAINFALL",
         "SNOWFALL")

minmax <- function(x){
  x_min = min(x)
  x_max = max(x)
  result = (x-x_min)/(x_max-x_min)
  return(result)
}
for (col in cols){
  value = minmax(bike_sharing_df[[col]])
  bike_sharing_df <- bike_sharing_df %>%
    mutate(!!sym(col) := value)
}

#for (col in cols){
#    bike_sharing_df <- bike_sharing_df %>%
#        mutate(values = minmax(bike_sharing_df$col))
#return
#}

# Print the summary of the dataset again to make sure the numeric columns range between 0 and 1
summary(bike_sharing_df)

# Save the dataset as `seoul_bike_sharing_converted_normalized.csv`
write_csv(bike_sharing_df, "seoul_bike_sharing_converted_normalized.csv")

# Dataset list
dataset_list <- c('seoul_bike_sharing.csv', 'seoul_bike_sharing_converted.csv', 'seoul_bike_sharing_converted_normalized.csv')

for (dataset_name in dataset_list){
  # Read dataset
  dataset <- read_csv(dataset_name)
  # Standardized its columns:
  # Convert all columns names to uppercase
  names(dataset) <- toupper(names(dataset))
  # Replace any white space separators by underscore, using str_replace_all function
  names(dataset) <- str_replace_all(names(dataset), " ", "_")
  # Save the dataset back
  write.csv(dataset, dataset_name, row.names=FALSE)
}


  mutate(TEMPERATURE = ifelse(is.na(TEMPERATURE), mean(TEMPERATURE, na.rm = TRUE), TEMPERATURE))