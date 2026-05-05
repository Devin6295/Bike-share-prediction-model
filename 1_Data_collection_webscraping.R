# Check if need to install rvest` library
require("rvest")
install.packages("rvest")
library(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_bicycle-sharing_systems"
# Get the root HTML node by calling the `read_html()` method with URL
root_node <- read_html(url)
table_nodes <- html_nodes(root_node, "table")

# Convert the bike-sharing system table into a dataframe
table_1 <- table_nodes[[1]]
df <- html_table(table_1, fill=TRUE)

# Summarize the dataframe
install.packages('tidyverse')
library(tidyverse)
df <- df[-2]
summary(df)

