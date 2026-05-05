library(tidyverse)

# Download raw_bike_sharing_systems.csv
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_bike_sharing_systems.csv"
download.file(url, destfile = "raw_bike_sharing_systems.csv")

# Download raw_cities_weather_forecast.csv
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_cities_weather_forecast.csv"
download.file(url, destfile = "raw_cities_weather_forecast.csv")

# Download raw_worldcities.csv
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_worldcities.csv"
download.file(url, destfile = "raw_worldcities.csv")

# Download raw_seoul_bike_sharing.csv
url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/raw_seoul_bike_sharing.csv"
download.file(url, destfile = "raw_seoul_bike_sharing.csv")

dataset_list <- c('raw_bike_sharing_systems.csv', 'raw_seoul_bike_sharing.csv', 'raw_cities_weather_forecast.csv', 'raw_worldcities.csv')

for (dataset_name in dataset_list){
  # Read dataset
  dataset <- read_csv(dataset_name)
  # Standardized its columns:
  
  # Convert all column names to uppercase
  colnames(dataset) <- toupper(colnames(dataset))
  # Replace any white space separators by underscores, using the str_replace_all function
  colnames(dataset) <- str_replace_all(colnames(dataset), " ", "_")
  # Save the dataset 
  write.csv(dataset, dataset_name, row.names=FALSE)
}

for (dataset_name in dataset_list){
  # Print a summary for each data set to check whether the column names were correctly converted
  df <- read_csv(dataset_name)
  print(head(df))
}

# First load the dataset
bike_sharing_df <- read_csv("raw_bike_sharing_systems.csv")

# Print its head
head(bike_sharing_df)

# Select the four columns
sub_bike_sharing_df <- bike_sharing_df %>% select(COUNTRY, CITY, SYSTEM, BICYCLES)

sub_bike_sharing_df %>% 
  summarize_all(class) %>%
  gather(variable, class)

# grepl searches a string for non-digital characters, and returns TRUE or FALSE
# if it finds any non-digital characters, then the bicyle column is not purely numeric
find_character <- function(strings) grepl("[^0-9]", strings)

sub_bike_sharing_df %>% 
  select(BICYCLES) %>% 
  filter(find_character(BICYCLES)) %>%
  slice(0:10)

# Define a 'reference link' character class, 
# `[A-z0-9]` means at least one character 
# `\\[` and `\\]` means the character is wrapped by [], such as for [12] or [abc]
ref_pattern <- "\\[[A-z0-9]+\\]"
find_reference_pattern <- function(strings) grepl(ref_pattern, strings)

# Check whether the COUNTRY column has any reference links
sub_bike_sharing_df %>% 
  select(COUNTRY) %>% 
  filter(find_reference_pattern(COUNTRY)) %>%
  slice(0:10)

# Check whether the CITY column has any reference links
sub_bike_sharing_df %>% 
  select(CITY) %>% 
  filter(find_reference_pattern(CITY)) %>%
  slice(0:10)

# Check whether the System column has any reference links
sub_bike_sharing_df %>% 
  select(SYSTEM) %>% 
  filter(find_reference_pattern(SYSTEM)) %>%
  slice(0:10)

# remove reference link
sub_bike_sharing_df <- bike_sharing_df %>% select(COUNTRY, CITY, SYSTEM, BICYCLES)
remove_ref <- function(strings) {
  ref_pattern <- "\\[[A-z0-9]+\\]"
  result <- stringr::str_replace_all(strings, ref_pattern, "") # Replace all matched substrings with a white space using str_replace_all()
  result <- trimws(result)# Trim the reslt if you want
  return(result)
}

# sub_bike_sharing_df %>% mutate(column1=remove_ref(column1), ... )
result <- sub_bike_sharing_df %>% dplyr::mutate(sub_bike_sharing_df, CITY=remove_ref(CITY), SYSTEM=remove_ref(SYSTEM))

result %>% 
  select(CITY, SYSTEM, BICYCLES) %>% 
  filter(find_reference_pattern(CITY) | find_reference_pattern(SYSTEM) | find_reference_pattern(BICYCLES))

# Extract the first number
extract_num <- function(columns){
  # Define a digital pattern
  digitals_pattern <- "\\d+"
  # Find the first match using str_extract
  result <- stringr::str_extract(columns, digitals_pattern)
  # Convert the result to numeric using the as.numeric() function
  return(as.numeric(result))
}

# Use the mutate() function on the BICYCLES column|
extracted_nums <- extract_num(result$BICYCLES)
result <- result %>%
  dplyr::mutate(BICYCLES = sapply(BICYCLES, extract_num))

summary(result$BICYCLES)
head(result)

# Write dataset to `bike_sharing_systems.csv`
write_csv(result, "bike_sharing_systems.csv")