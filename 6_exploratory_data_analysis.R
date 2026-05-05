# provide your solution here
library(readr)

seoul_bike_sharing <- read_csv("https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/seoul_bike_sharing.csv" )

seoul_bike_sharing$DATE <- as.character(seoul_bike_sharing$DATE)
seoul_bike_sharing$SEASONS <- as.factor(seoul_bike_sharing$SEASONS)
seoul_bike_sharing$HOLIDAY <- as.factor(seoul_bike_sharing$HOLIDAY)
seoul_bike_sharing$FUNCTIONING_DAY <- as.factor(seoul_bike_sharing$FUNCTIONING_DAY)

# provide your solution here
seoul_bike_sharing$DATE <- as.Date(seoul_bike_sharing$DATE, format = "%d/%m/%Y")

# provide your solution here
seoul_bike_sharing$HOUR <- as.factor(seoul_bike_sharing$HOUR)

str(seoul_bike_sharing)

sum(is.na(seoul_bike_sharing))

#Summary of dataset
summary(seoul_bike_sharing)

#number of holidays
sum(seoul_bike_sharing$HOLIDAY == "Holiday")/24

#percent of records on a holiday
(sum(seoul_bike_sharing$HOLIDAY == "Holiday")/length(seoul_bike_sharing$HOLIDAY))*100

# number of expected records
365*24

# number of records on non holiday
length(seoul_bike_sharing$FUNCTIONING_DAY)

#summarize data by season
library(dplyr)
info <- seoul_bike_sharing %>% 
  group_by(SEASONS) %>%
  summarise(
    Total_Rain = sum(RAINFALL),
    Total_Snow = sum(SNOWFALL)
  )
head(info)

library(ggplot2)

# scatter plot of rented bike vs date
ggplot(seoul_bike_sharing, aes(x=DATE, y=RENTED_BIKE_COUNT)) +
  geom_point(color = "steelblue", alpha = 0.4, size = 1) +
  labs(
    title = "Rented Bike Count vs Date",
    x     = "Date",
    y     = "Rented Bike Count")

#add hours as color
ggplot(seoul_bike_sharing, aes(x=DATE, y=RENTED_BIKE_COUNT, color=HOUR)) +
  geom_point(alpha = 0.4, size = 1) +
  labs(
    title = "Rented Bike Count vs Date",
    x     = "Date",
    y     = "Rented Bike Count")

# create histogram of rented bike count
ggplot(seoul_bike_sharing, aes(x = RENTED_BIKE_COUNT)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins   = 30,
                 fill   = "white",
                 color  = "black",
                 alpha  = 0.7) +
  labs(
    title = "Distribution of Rented Bike Count",
    x     = "Rented Bike Count",
    y     = "Density"
  )

# correlate rented bikes by temperature and split by season
ggplot(seoul_bike_sharing, aes(x=TEMPERATURE, y=RENTED_BIKE_COUNT, color=HOUR)) +
  geom_point(alpha = 0.4, size = 1) +
  labs(
    title = "Rented Bike Count vs Date",
    x     = "Date",
    y     = "Rented Bike Count") +
  facet_wrap(~SEASONS)

ggplot(seoul_bike_sharing) +
  geom_point(aes(x=TEMPERATURE,y=RENTED_BIKE_COUNT,colour=HOUR),alpha=1/5)

# rented bike vs hour
ggplot(seoul_bike_sharing, aes(x=HOUR, y=RENTED_BIKE_COUNT)) +
  geom_boxplot() +
  labs(x="Hour",
       y="Rented Bike Count") +
  facet_wrap(~SEASONS)

#calculate rainfall and snowfall
library(dplyr)
info2 <- seoul_bike_sharing %>% 
  group_by(DATE) %>%
  summarise(
    Total_Rain = sum(RAINFALL),
    Total_Snow = sum(SNOWFALL)
  )
print(info2)

# find number of days with snowfall
ggplot(info2, aes(x=DATE, y=DATE))

