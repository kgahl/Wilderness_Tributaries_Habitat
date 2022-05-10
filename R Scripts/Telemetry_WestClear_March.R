#West Clear Telemetry Data for March
#Kaitlyn Gahl
#2022-4-5

##Packages Used
library(readr)
library(tidyverse)
library(dplyr)
library(tidyr)

######################################################################################################################
### DATA WRANGLING ##################################################################################################### 
###   Manipulate multiple data frames to combine and organize different aspects. End result will be 
###   one data frame with the necessary data to perform Habitat Suitability statistical analysis.  

### Reorganize Cover Type and Percentage data within Habitat Data dataframe 
## Import raw Habitat Data
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

## Remove % sign from Instream Cover Percentage columns 
gsub( "%", "", as.character(c('Instream Cover Percentage (1)',
                              'Instream Cover Percentage (2)',
                              'Instream Cover Percentage (3)')))

## Make Separate Data for Type 1, Type 2, and Type 3 columns
Instream_Cover1 <- Habitat_Data %>%
  select(c(`ObjectID`, 'Instream Cover Type (1)', `Instream Cover Percentage (1)`)) %>%
  rename(Cover_Type = 'Instream Cover Type (1)') %>%
  rename(Cover_Percentage = 'Instream Cover Percentage (1)') %>%
  filter(!is.na(Cover_Type))

Instream_Cover2 <- Habitat_Data %>%
  select(c(`ObjectID`, 'Instream Cover Type (2)', `Instream Cover Percentage (2)`)) %>%
  rename(Cover_Type = 'Instream Cover Type (2)') %>%
  rename(Cover_Percentage = 'Instream Cover Percentage (2)') %>%
  filter(!is.na(Cover_Type))
  
Instream_Cover3 <- Habitat_Data %>%
  select(c(`ObjectID`, 'Instream Cover Type (3)', `Instream Cover Percentage (3)`)) %>%
  rename(Cover_Type = 'Instream Cover Type (3)') %>%
  rename(Cover_Percentage = 'Instream Cover Percentage (3)') %>%
  filter(!is.na(Cover_Type))

## Combine all Data Frames
Cover_Long <- Instream_Cover1 %>%
  bind_rows(Instream_Cover2, Instream_Cover3) %>%
  arrange(`ObjectID`)

#Transform Cover_Long to wide format
Cover_Wide <- Cover_Long %>%
  pivot_wider(id_cols = `ObjectID`, 
              names_from = Cover_Type,
              values_from = Cover_Percentage)

## Delete instream cover columns from Habitat Data 
Habitat_Data[10:15] <- list(NULL)

### SOMETHING WENT WRONG HERE. SUBSTRATES ALL READ 0

## Join Habitat Data and Cover Wide, Replace NA with 0 in cover columns 
Habitat_Data <- left_join(Habitat_Data, Cover_Wide, by = "ObjectID") %>%
  mutate(across('Substrate_Feature':'Terrestrial_Vegetation', ~replace_na(0))) 

view(Habitat_Data)
remove(Instream_Cover1, Instream_Cover2, Instream_Cover3, Cover_Long, Cover_Wide)

### Add individual fish data from Radio Tagged Fish to Habitat Data data frame -establish species for each tag number
## Import Radio Tagged Fish data and change "Tag" column name to "Tag Number" 
Radio_Tagged_Fish <- read_csv("data/raw/Radio_Tagged_Fish.csv",
                                na =c("","na"))

Radio_Tagged_Fish <- Radio_Tagged_Fish %>%
  rename('Tag_Number' = 'Tag')
                                 
View(Radio_Tagged_Fish)

## Merge Radio Tagged Fish and Habitat Data 
Fish_And_Habitat <- Habitat_Data %>%
  merge(Radio_Tagged_Fish, Habitat_Data, by.x = 'Tag_Number', by.y = 'Tag_Number', 
        all.x = TRUE) %>%
  rename('Site_Type' = 'Site Type')


  
remove(Habitat_Data, Radio_Tagged_Fish)
view(Fish_And_Habitat)

#######################################################################################################################
### DESERT SUCKER#####################################################################################################
### Create Use vs Availability Habitat Selection for Desert Sucker 

# Isolate desert sucker observations from the data set with filter
# select what variables(columns) from the data set to include

DS_Data <- Fish_And_Habitat %>% 
  filter(Species == 'Desert Sucker') %>% 
  select('Species', 'Depth (cm)', 'Velocity (m/s)', 'Substrate', 'Canopy Cover', 'Mesohabitat', 'Site Type')
        # Need to combine habitat cover percentages to get one number then include Instream Cover in this select

# Make a dataset of all available locations to be used in use v availability framework

Available <- Fish_And_Habitat %>% 
  filter('Site Type' == "Available") %>% 
  select('Species', 'Depth (cm)', 'Velocity (m/s)', 'Substrate', 'Canopy Cover', 'Mesohabitat', 'Site Type')


