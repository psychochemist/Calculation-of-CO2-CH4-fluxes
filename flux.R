#### calculate fluxes with package fluxCal ####

## IMPORTANT: to run the script there is no need to change directories in read.csv command. Download script and folder "data" into the same folder. 

setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set working directory to location where script is located. 
getwd() # check if working directory is set correct

# load packages
# If FluxCalR package is not installed yet remove '#' below and run:
# install.packages("remotes")
# remotes::install_github("junbinzhao/FluxCalR",build_vignettes = TRUE)
# if this method doesn't work, then:
# install.packages("devtools")
# library('devtools')
# githubinstall('FluxCalR')

library(FluxCalR)
library(tidyverse)
library(chron)
library(mgcv)

# Start / End cues ----
time_cue <- read.csv("./data/start_end.csv", sep=",", header = TRUE, fileEncoding="UTF-8-BOM") # import start and end times into R
# removal of the measurements in the morning as being the test measurements
time_cue <- time_cue[!grepl("A", time_cue$Plot) & !grepl("_1", time_cue$Plot),] 
# add leading 0 to start and end time when needed (e.g. 956 -> 0956)
time_cue$start <- formatC(time_cue$start, width = 4, format = 'd', flag = '0')
time_cue$end <- formatC(time_cue$end, width = 4, format = 'd', flag = '0')

# convert start and end times from hhmm or hhmmss to hh:mm:ss
time_cue$start <- ifelse(test = nchar(time_cue$start)==6, yes = format(strptime(time_cue$start, format = "%H%M%S"), format = "%H:%M:%S"), no = format(strptime(time_cue$start, format = "%H%M"), format = "%H:%M:%S"))
time_cue$end <- ifelse(test = nchar(time_cue$end)==6, yes = format(strptime(time_cue$end, format = "%H%M%S"), format = "%H:%M:%S"), no = format(strptime(time_cue$end, format = "%H%M"), format = "%H:%M:%S"))

# merge date and time columns
time_cue$Start <- paste(time_cue$date,time_cue$start)
time_cue$End <- paste(time_cue$date,time_cue$end)

time_cue$Start <- as.POSIXct(time_cue$Start,format='%d/%m/%Y %H:%M:%S') # format date time to format R recognizes as such
time_cue$End <- as.POSIXct(time_cue$End,format='%d/%m/%Y %H:%M:%S') # format date time to format R recognizes as such

time_constant <- 30 # !ADJUST! constant for time-difference adjustment in seconds between gga time and actual time (in seconds), adjust accordingly. real time = gga time + time_constant

time_cue$start <- time_cue$Start+time_constant
time_cue$end <- time_cue$End+time_constant # start/end = real time, required for temp and par, and Start/End = gga time. these might be the same if gga time is synchronised before measurement.

# Chamber PAR and/or Temp logger ----
d <- read.csv("./data/light_temp.csv", sep=",", header = TRUE, fileEncoding="UTF-8-BOM") # import light_temp data into R make sure filenames are correct and in "data" folder of working directory. It contains the par and temperature data of low frequency measurements
d_temp <- read.csv("./data/temp.csv", sep=",", header = TRUE, fileEncoding="UTF-8-BOM") # import temperature data with higher measurement frequency
names(d) <- c("dt", "par", "temp", "date", "time") # rename columns
d$date <- format(d$date, tryFormats= "%d-%m-%Y", format='%d-%m-%y') # format date time to format R recognizes as such
d$time <- chron(times=d$time)
d$dt <- paste(d$date, d$time) 
d$dt <- as.POSIXct(d$dt, format='%d-%m-%Y %H:%M:%S')
d_temp$date <- format(d_temp$date, tryFormats= "%d-%m-%Y", format='%d-%m-%y') # format date time to format R recognizes as such
d_temp$time <- chron(times=d_temp$time)
d_temp$dt <- paste(d_temp$date, d_temp$time) 
d_temp$dt <- as.POSIXct(d_temp$dt, format='%d-%m-%Y %H:%M:%S')

# create columns for average temp and par during chamber measurement
time_cue$par <- NA
time_cue$temp <- NA
#Since the measurements of the fluxes were higher frequency than those of par and temperature, general additive model was created to calculate the par and temperature for the timestamps of the flux measurements. 

# check fluctuation of the par
plot(d$time, d$par)
# based on  the plot GAM is applied to find the par for timestamps when fluxes were measured 

par_gam <- gam(par~s(time), data=d)
dummy1<-seq(from=min(d$time),to=max(d$time), length=1000)
yPredicted_par <- predict(par_gam,newdata=data.frame(time=dummy1))
lines(dummy1,yPredicted_par,col="red")

# check the temperature fluctuation 
plot(d_temp$time, d_temp$temp)
# based on  the plot GAM is applied to find the temperature for timestamps when fluxes were measured

temp_gam <- gam(temp~s(time), data=d_temp)
dummy2<-seq(from=min(d_temp$time),to=max(d_temp$time), length=1000)
yPredicted_temp <- predict(temp_gam, newdata = data.frame(time=dummy2))
lines(dummy2,yPredicted_temp,col="red")


# Predicting the values of temperature and par based on the models, for every second of the day.
model_d <- data.frame(dt=seq(from=as.POSIXct("2021-09-22 00:00:01"),to=as.POSIXct("2021-09-23 00:00:00"),by="sec"))
model_d$time <- chron(times=strftime(model_d$dt, "%H:%M:%S"))
converTime <- seq(from=min(model_d$time), to=max(model_d$time),length=86400)
model_d$par <- predict(par_gam, newdata = data.frame(time=converTime))
model_d$temp <- predict(temp_gam, newdata=data.frame(time=converTime))


time_cue$par <- NA
time_cue$temp <-  NA
# calculate par average during chamber measurement 
for(x in seq_len(nrow(time_cue))){
  time_cue$par[x] <- mean(model_d[(model_d$dt >= time_cue$start[x] & model_d$dt  <= time_cue$end[x]),]$par)
}

# calculate temp average during chamber measurement

for(i in seq(nrow(time_cue))){
  time_cue$temp[i] <- mean(model_d[(model_d$dt >= time_cue$start[i] & model_d$dt <= time_cue$end[i]),]$temp)
}


# clean up!
remove(d, d_temp, dummy1, dummy2, yPredicted_par, yPredicted_temp, converTime, model_d)

# Data preparation ----

# first import .data file and make dataset suitable for calculations
temp <- read.delim("./data/licor.data", header = T, skip = 5) # import .data file and skip first 5 lines
temp <- temp[-1,] # delete 1st row

temp[temp=="nan"] <- NA # replace empty measurement points with actual empty cells

df <- na.omit(temp) # remove rows with empty cells

df$dt <- paste(df$DATE, df$TIME) # combine date and time columns into one column

df$CO2 <- as.numeric(df$CO2) # convert character to numeric
df$CH4 <- as.numeric(df$CH4)/1000 # convert CH4 from ppb to ppm


dates <- split(df$DATE, df$DATE) # create list of dates when dataset covers multiple days

un <- unlist(dates)
dates <- Map(`[`, dates, relist(!duplicated(un), skeleton = dates))

# create subsets per day of the gas analyser data repeat the below code for each day of measurements
df1 <- df %>%
  filter(DATE == dates[[1]])

time_cue <- time_cue %>% # rename temperature column so FluxCalR package recognizes it.
  rename(Ta = temp)

# prepare time_cue for flux calculations

tubeD <- .4 # tube diameter in cm

time_cue$ChamberA <- (time_cue$ChamberD/2)^2*pi # chamber area in cm
time_cue$ChamberV <- (((time_cue$ChamberA*time_cue$ChamberH)+((tubeD/2)^2*pi*time_cue$TubeL))/1000)+(time_cue$SafetyC/1000) # calculate chamber volume in L

time_cue$End <- time_cue$End+30 # add x seconds to end time because of lag due to length of tube

time_cue$Date <- as.Date(time_cue$Start)

time_cue$Start <- strftime(time_cue$Start, format='%H:%M:%S') # strip time from start and end times so the FluxCalR package recognizes it
time_cue$End <- strftime(time_cue$End, format='%H:%M:%S')


# subset time_cue for each day of measurements (repeat below code for each seperate day)
time_cue_1 <- subset(time_cue, Date==dates[[1]])


ChamberV <- min(time_cue$ChamberV)

# crop dataset to cut off the measurements at startup and when machine is turned off

df1 <- subset(df1, dt>=(min(time_cue_1$start, n=1)-300) & dt <=(max(time_cue_1$end)+300))


# save dataframes as .txt to be able to use in flux calculations later

write.table(x=df1, file="./data/licor1.txt", quote = FALSE, row.names = FALSE, sep = ",") # THIS TAKES A WHILE: save as txt to be able to use in FluxCalR package


# pressure convertion from kPa to atm. The first number is the mean pressure for the day of the measurement and second is the conversion variable

pressure_day1 <- 102.917894736842*9.8692316931427E-3 


# clean up
remove(temp,df1,df, time_cue, un, time_constant)


# Flux calculation ----

# import data (repeat below code for each day)

data1 <- LoadOther(file="./data/licor1.txt", sep =","  , time = "dt", time_format = "ymd_HMS", CO2 = "CO2", CH4 = "CH4", row.names=NULL)

data1 <- data1 %>%
  filter(X.CO2.d_ppm<=1000 & X.CO2.d_ppm>=100) # filter out very low/high measurements (occur when machine is turned on/off)



# calculate the fluxes and check the graph if correct part of slope is used. write down any measurements were wrong part of slope is used.
# CO2 = longer time window

CO2 <- FluxCal(data=data1,
               win=2,
               vol=ChamberV,
               area=time_cue_1$ChamberA/10000,
               cal="CO2",
               df_cue=time_cue_1,
               cue_type = "Start_End",
               df_Ta = time_cue_1,
               output = FALSE,
               ext =1.5,
               metric = "RMSE",
               pa = pressure_day1,
               other = c("Plot", "L_D", "ChamberA", "ChamberV", "par"),
               digits = 5)

# CH4 = shorter time window because of CH4 bubbles. also measurements are really precise, so time window can be short to get accurate flux
CH4 <- FluxCal(data=data1,
                    win=1,
                    vol=ChamberV,
                    area=time_cue_1$ChamberA/10000,
                    cal="CH4",
                    df_cue=time_cue_1,
                    cue_type = "Start_End",
                    df_Ta = time_cue_1,
                    output = FALSE,
                    ext = 4,
                    metric = "RMSE",
                    pa = pressure_day1,
                    other = c("Plot", "L_D", "ChamberA", "ChamberV", "par"),
                    digits = 5)

# Time adjustments sometimes are required, therefore the following code can be applied
# In this example, adjustments for CH4 were done, by changing the 'Start' time at Num==7 
# CH4_time_cue <- CH4 %>%
#   filter(Num=='7') #filtering out the the values at row Num==7
# 
# CH4_time_cue$Start[CH4_time_cue$Num=='7'] <- '11:17:00' # change of the 'Start' time
# 
# # recalcualtion of the flux for adjusted values 
# CH4_adjusted <- FluxCal(data=data1,
#                         win=1,
#                         vol=ChamberV,
#                         area=CH4_time_cue$ChamberA/10000,
#                         cal="CH4",
#                         df_cue=CH4_time_cue,
#                         cue_type = "Start_End",
#                         df_Ta = CH4_time_cue,
#                         output = FALSE,
#                         ext =4,
#                         metric = "RMSE",
#                         pa = pressure_day1,
#                         other = c("Plot", "L_D","ChamberA", "ChamberV","par","Num"),
#                         digits = 5)
# 
# # renaming the rows, so the will be the same in both data frames 
# rownames(CH4_adjusted) <- CH4_adjusted[,1] 
# rownames(CH4) <- CH4[,1]
# # combining adjusted values with initial calculations
# CH4_final <- rbind(CH4_adjusted, CH4[!rownames(CH4) %in% rownames(CH4_adjusted),])

# In this study, no adjustments were required, hence we can proceed with the calculated data.

CO2_final <- CO2 
CH4_final <- CH4


CO2_fluxes <- CO2_final
CH4_fluxes <- CH4_final


CH4_molarmass <- 16.04246 # CH4 molar mass 
CO2_molarmass <- 44.0095 # CO2 molar nass

# convert fluxes from umol/m2/s to mg/m2/d
CH4_fluxes$Flux_mg <- (CH4_fluxes$Flux*CH4_molarmass/1000)*60*60*24
CO2_fluxes$Flux_mg <- (CO2_fluxes$Flux*CO2_molarmass/1000)*60*60*24

# combining flux calculations in one data frame
fluxes <- rbind(CO2_fluxes, CH4_fluxes)


fluxes$Date <- as.Date(fluxes$Date, "%Y-%m-%d", tz = "Amsterdam")


# correct for volume difference between plots if the differen chambers are used 
fluxes$vol_correction <- fluxes$ChamberV/ChamberV
fluxes$Flux_corrected <- fluxes$Flux_mg*fluxes$vol_correction


# save results as csv
fluxes <- dplyr::arrange(fluxes,Gas,Date,Start)
write.table(x=fluxes, file="fluxes.csv", quote = FALSE, row.names = FALSE, sep = ",")

