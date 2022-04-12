#West Clear Telemetry Data for March
#Kaitlyn Gahl
#2022-4-5

##Packages Used
library(readr)
library(tidyverse)
library(dplyr)
library(tidyr)

##Import Habitat Data
Habitat_Data <- read_csv("data/raw/WestClear_Telemetry_Habitat_March.csv", 
                         na =c("","na"),
                         col_types = cols(ObjectID = col_number(), 
                                          `Tag Number` = col_number(), `Stream Width (m)` = col_number(), 
                                          `Other - Mesohabitat` = col_skip(), 
                                          `Depth (cm)` = col_number(), `Velocity (m/s)` = col_number(), 
                                          'Instream Cover Percentage (1)' = col_number(),
                                          `Instream Cover Percentage (2)` = col_number(), 
                                          `Instream Cover Percentage (3)` = col_number(), 
                                          `Date and Time` = col_date(format = "%m/%d/%Y"), 
                                          `Temperature (C)` = col_number()))
#View(Habitat_Data)

## Remove % sign from Instream Cover Percentage columns 
gsub( "%", "", as.character(Habitat_Data))
#view(Habitat_Data)

## Unite Instream Cover and Percent for (1)(2)(3)
unite(Habitat_Data, col = "Instream Cover 1", c("Instream Cover Type (1)", "Instream Cover Percentage (1)"), sep = "-")
unite(Habitat_Data, col = "Instream Cover 2", c("Instream Cover Type (2)", "Instream Cover Percentage (2)"), sep = "-")
unite(Habitat_Data, col = "Instream Cover 3", c("Instream Cover Type (3)", "Instream Cover Percentage (3)"), sep = "-")

####unite(Habitat_Data, col = "Instream_Cover_1", (Instream Cover Type (1)|Instream Cover Percentage (1)), sep = "-")
####print(Habitat_Data[,Instream_Cover_1,drop=FALSE])

view(Habitat_Data)
head(Habitat_Data)
  
## Gather Instream Cover 1, 2, 3 to create a 1,2,3 and type/percent column
# gather(Habitat_Data, "1, 2, 3", "Type Percent", column numbers to gather from- likely 10:12)

## Remove column "1, 2, 3"
# add '1, 2, 3' = col_skip() to Import Habitat Data

## Separate Type Percent column into type and percent 
# separate(Habitat_Data, col=Type Percent, into=c('Type', 'Percent'), sep='-')

## Spread Type and Percent so Type observations become variables (columns) 
# spread(Habitat_Data, key=Type, value=Percent)



# #Import Fish Data 
# Fish_Data <- read_csv("data/raw/Radio_Tagged_Fish.csv", 
#                       col_types = cols(Tag = col_number(), 
#                                        Weight = col_number(), Length = col_number(), 
#                                        `Capture Date` = col_date(format = "%m/%d/%Y"), 
#                                        Release = col_skip(), Notes = col_skip()))
# View(Fish_Data)
# 
# tibble::as_tibble(Habitat_Data)
# 
# 
# 
# 
# #Join Habitat_Data and Fish Data
# left_join(Habitat_Data, Fish_Data, by = "Tag")

