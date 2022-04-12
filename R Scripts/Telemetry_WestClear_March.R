#West Clear Telemetry Data for March
#Kaitlyn Gahl
#2022-4-5

#Packages Used
library(readr)
library(tidyverse)
library(dplyr)

#Import Habitat Data
Habitat_Data <- read_csv("data/raw/WestClear_Telemetry_Habitat_March.csv", 
                         col_types = cols(ObjectID = col_number(), 
                                          `Tag Number` = col_number(), `Stream Width (m)` = col_number(), 
                                          `Other - Mesohabitat` = col_skip(), 
                                          `Depth (cm)` = col_number(), `Velocity (m/s)` = col_number(), 
                                          `Instream Cover Percentage (1)` = col_number(), 
                                          `Instream Cover Percentage (2)` = col_number(), 
                                          `Instream Cover Percentage (3)` = col_number(), 
                                          `Date and Time` = col_date(format = "%m/%d/%Y"), 
                                          `Temperature (C)` = col_number()))
View(Habitat_Data)
rename(Habitat_Data, "Tag" = "Tag Number")
 
#Import Fish Data 
Fish_Data <- read_csv("data/raw/Radio_Tagged_Fish.csv", 
                      col_types = cols(Tag = col_number(), 
                                       Weight = col_number(), Length = col_number(), 
                                       `Capture Date` = col_date(format = "%m/%d/%Y"), 
                                       Release = col_skip(), Notes = col_skip()))

#Join Habitat_Data and Fish Data
left_join(Habitat_Data, Fish_Data, by = tag)


