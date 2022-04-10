#West Clear Telemetry Data for March
#Kaitlyn Gahl
#2022-4-5

#Packages Used
library(readr)
library(tidyverse)
library(dplyr)

#Import Data
WestClear_Telemetry_Habitat_March <- read_csv("data/raw/WestClear_Telemetry_Habitat_March.csv", 
                                              col_types = cols(ObjectID = col_number(), 
                                                               `Site Type` = col_character(), `Tag Number` = col_number(), 
                                                               `Stream Width (m)` = col_number(), 
                                                               `Other - Mesohabitat` = col_skip(), 
                                                               `Depth (cm)` = col_number(), `Velocity (m/s)` = col_number(), 
                                                               `Canopy Cover` = col_character(), 
                                                               `Instream Cover Percentage (1)` = col_number(), 
                                                               `Instream Cover Percentage (2)` = col_number(), 
                                                               `Instream Cover Type (3)` = col_character(), 
                                                               `Instream Cover Percentage (3)` = col_number(), 
                                                               `Date and Time` = col_date(format = "%m/%d/%Y"), 
                                                               `Temperature (C)` = col_number()))
View(WestClear_Telemetry_Habitat_March)


