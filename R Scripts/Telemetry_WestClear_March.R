#West Clear Telemetry Data for March
#Kaitlyn Gahl
#2022-4-5

##Packages Used
library(readr)
library(tidyverse)
library(dplyr)
library(tidyr)
library(lme4)
library(ggplot2)
library(glmmTMB)


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

## Transform Cover_Long to wide format
Cover_Wide <- Cover_Long %>%
  pivot_wider(id_cols = `ObjectID`, 
              names_from = Cover_Type,
              values_from = Cover_Percentage)

## Delete instream cover columns from Habitat Data 
Habitat_Data[10:15] <- list(NULL)

### SOMETHING WENT WRONG HERE. SUBSTRATES ALL READ 0

## Join Habitat Data and Cover Wide, Replace NA with 0 in cover columns 
Habitat_Data <- left_join(Habitat_Data, Cover_Wide, by = "ObjectID") %>%
  mutate(across('Substrate_Feature':'Terrestrial_Vegetation', ~replace_na(0))) %>%
  rename('Site_Type' = 'Site Type',
         'Tag_Number' = 'Tag Number',
         'Stream_Width_m' = 'Stream Width (m)',
         'Depth_cm' = 'Depth (cm)',
         'Velocity' = 'Velocity (m/s)',
         'Canopy_Cover' = 'Canopy Cover',
         'Stream_Name' = 'Stream Name',
         'Date_Time' = 'Date and Time',
         'Temperature_C' = 'Temperature (C)') 

## Correct innacurate data in cell 67,2 (available to occupied)  
Habitat_Data [67, 2] = 'Occupied'

view(Habitat_Data)
remove(Instream_Cover1, Instream_Cover2, Instream_Cover3, Cover_Long, Cover_Wide)

### Add individual fish data from Radio Tagged Fish to Habitat Data data frame -establish species for each tag number
## Import Radio Tagged Fish data and change "Tag" column name to "Tag Number" 
Radio_Tagged_Fish <- read_csv("data/raw/Radio_Tagged_Fish.csv",
                                na =c("","na")) %>%
  rename('Tag_Number' = 'Tag',
         'Capture_Method' = 'Capture Method',
         'Capture_Date' = 'Capture Date')
                                 
View(Radio_Tagged_Fish)

## Merge Radio Tagged Fish and Habitat Data 
Fish_And_Habitat <- Habitat_Data %>%
  merge(Radio_Tagged_Fish, Habitat_Data, by.x = 'Tag_Number', by.y = 'Tag_Number', 
        all.x = TRUE)
  
remove(Habitat_Data, Radio_Tagged_Fish)
view(Fish_And_Habitat)

#######################################################################################################################
### DESERT SUCKER#####################################################################################################
### Prepare Use vs Availability Habitat Selection for Desert Sucker 

## Isolate desert sucker observations from the data set with filter. 
##   Select what variables(columns) from the data set to include
DS_Occupied <- Fish_And_Habitat %>% 
  filter(Species == 'Desert Sucker') %>% 
  select('Species', 'Depth_cm', 'Velocity', 'Substrate', 'Canopy_Cover', 'Mesohabitat', 'Site_Type')
        # Need to combine habitat cover percentages to get one number then include Instream Cover in this select

## Make a data set of all available locations to be used in use v availability framework
Available <- Fish_And_Habitat %>% 
  filter(Site_Type == 'Available') %>% 
  select('Species', 'Depth_cm', 'Velocity', 'Substrate', 'Canopy_Cover', 'Mesohabitat', 'Site_Type')

## Combine Desert Sucker occupied and available to be used in 'use vs availability'
DS_Data <- rbind(DS_Occupied, Available)

remove(DS_Occupied, Available, Fish_And_Habitat)
  
## Trying to convert yes no to 1 0  
#   DS_Data$
# Canopy_Cover <- as.character(Canopy_Cover) 
#                    
#   
# 
# DS_Data$Canopy_Cover <- ifelse(DS_Data$Canopy_Cover == "Yes",1,0)
#                                
# levels('Canopy_Cover') <- c("0", "1")
# 
# DS_Data[DS_Data == "yes"] <- 1
# DS_Data[DS_Data == "no"] <- 0                              
# 
# Canopy_Cover['Canopy_Cover' == "Yes"] <- 1
# DS_Data['Canopy_Cover' == "No"] <- 0 
# DS_Data <- as.numeric('Canopy_Cover')


### Standardize the data
## This makes the mean and standard deviation of each of the following variables 0 and 1 respectively which helps in 
## the interpretation of the regressions. I don't know why....

# ## Depth
# x <- mean(DS_Data$Depth_cm)
# DS_Data$Depth_std <- (DS_Data$Depth_cm - x) / sd(DS_Data$Depth_cm)
# sd(DS_Data$depth_std) #check to make sure SD is 1

# ## Velocity
# y <- mean(DS_Data$'Velocity')
# DS_Data$Velocity_std <- (DS_Data$'Velocity' - y) / sd(DS_Data$'Velocity')
# sd(DS_Data$Velocity_std) #check to make sure SD is 1

# ## Canopy Cover
# z <- mean(DS_Data$Canopy_Cover)
# DS_Data$Canopy_Cover_std <- (DS_Data$Canopy_Cover - z) / sd(DS_Data$Canopy_Cover)
# sd(DS_Data$Canopy_Cover_std) #check to make sure SD is 1

# remove(x, y)

## Generalized linear regression: Logistic regression
# Normal additive model
# RTC.Global <- glmer(Site_Type ~ Depth_cm + Velocity + Substrate + Canopy_Cover + Mesohabitat,
#                    family = "binomial",
#                    data = DS_Data, control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5)))
# 
# # # RTC.Global<- glmer(Present ~ depth_std + Velo_std + Substrate + PercentCover_std + MacroHab, 
# # family = "binomial",
# # data = Roundtail.data, control=glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5)))
# 
# 
# summary(RTC.Global)
# 
# plot(allEffects(RTC.Global)) # Plot of model (effects package required)
# 
# r2(RTC.Global) # Conditional and marginal R2 (performance package required)
# #conditional = 0.563
# #Marginal = 0.525
