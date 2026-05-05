#install.packages("rlang")
#install.packages("tidymodels")

library("tidymodels")
library("tidyverse")
library("stringr")

# Dataset URL
dataset_url <- "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/IBMDeveloperSkillsNetwork-RP0321EN-SkillsNetwork/labs/datasets/seoul_bike_sharing_converted_normalized.csv"
bike_sharing_df <- read_csv(dataset_url)
spec(bike_sharing_df)

bike_sharing_df <- bike_sharing_df %>% 
  select(-DATE, -FUNCTIONING_DAY)

# Use the `initial_split()`, `training()`, and `testing()` functions to split the dataset
# With seed 1234
set.seed(1234)
# prop = 3/4
split_df <- initial_split(bike_sharing_df, prop=0.75)
# train_data 
training_df <- training(split_df)
# test_data
testing_df <- testing(split_df)

# Use `linear_reg()` with engine `lm` and mode `regression`
model_spec <- linear_reg(mode="regression", engine="lm")

# Fit the model called `lm_model_weather`
# RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED + VISIBILITY + DEW_POINT_TEMPERATURE + SOLAR_RADIATION + RAINFALL + SNOWFALL,  with the training data
lm_model_weather <- lm(RENTED_BIKE_COUNT ~ TEMPERATURE + HUMIDITY + WIND_SPEED + VISIBILITY + DEW_POINT_TEMPERATURE + SOLAR_RADIATION + RAINFALL + SNOWFALL, data=training_df)

summary(lm_model_weather)

# Fit the model called `lm_model_all`
# `RENTED_BIKE_COUNT ~ .` means use all other variables except for the response variable
lm_model_all <- lm(RENTED_BIKE_COUNT~ ., data=training_df)

summary(lm_model_all)

# test_results_weather for lm_model_weather model
test_results_weather <- predict(lm_model_weather)
# test_results_all for lm_model_all
test_results_all <- predict(lm_model_all)

test_df <- testing_df$RENTED_BIKE_COUNT 

print(head(testing_df))
print(head(test_results_all))

#rsq_weather <- rsq(test_results_weather)
#rsq_all <- rsq(testtest_results_all)

#rmse_weather <- rmse(test_results_weather)
#rmse_all <- rmse(test_results_all)

mse_weather <- mean(lm_model_weather$residuals^2)
rmse_weather <- sqrt(mse_weather)
r2_weather <- summary(lm_model_weather$r.squared)

mse_all <- mean(lm_model_all$residuals^2)
rmse_all <- sqrt(mse_all)
r2_all <- summary(lm_model_all$r.squared)

coefs <- lm_model_all$coefficients

# Sort coefficient list
coef_df <- data.frame(
  Variable    = names(coef(lm_model_all)),
  Coefficient = as.numeric(coef(lm_model_all))
) %>%
  arrange(desc(Coefficient))


# Visualize the list using ggplot and geom_bar
library(ggplot2)

ggplot(coef_df, aes(x = reorder(Variable, Coefficient), y = Coefficient)) +
  geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
  coord_flip() +
  labs(
    title = "Model Coefficients",
    x     = "Variable",
    y     = "Coefficient"
  ) +
  theme_minimal()

