# Calculation-of-CO2-CH4-fluxes
# Application of FluxCalR package in R to calculate fluxes of carbon dioxide (CO2) and methane (CH4), based on the data acquired by using the static chamber. 
## Background information about data
As a part of the university project, the fluxes of CO2 and CH4 were measured with a Trace gas analyser (LI-810 CH4/CO2/H2O Trace Gas Analyzer, LI-COR, Lincoln, NE, U.S.A; frequency: 1 Hz; precision level: 0.60 ppb for CH4 and 3.5 ppm for CO2). The Trace Gas Analyzer was linked to a closed acrylic chamber (51 cm x 33 cm x 18 cm) which was placed above the soil.

The air temperature, atmospheric pressure and photosynthetic active radiation were acquired from the weather station.

All data was collected on the island of Terschelling, in the Netherlands, as a part of a student project of the Radboud University. 

## FluxCalR package application and metadata
My part in the project was to perform data analysis, including the extraction of data from the gas analyser. 

The script presented in this repository is supposed to show the application of the FluxCalR package for the calculation of fluxes, by use of metadata. 
The given .csv files of the metadata can be updated with new data.

### Description of metadata
- start_end.csv
  - Plot: "name" - *the name of the sites where the measurements were taken*
  - L_D: "Light" or "Dark" - *the parameter of illumination which indicates whether the measurements were done at light or dark conditions*
  - date: dd/mm/yy - *the date of the measurement*
  - start: hhmmss - *the start point of measurement*
  - end: hhmmss - *the end point of measurement*
  - TubeL: x - *the length of the tube connecting the analyser to the chamber in cm*
  - SafetyC: x - *the volume of the safety chamber in cm<sup>3</sup>*
  - ChamberH: x - *the height of the chamber in cm* 
  - ChamberD: x - *the diameter of the chamber in cm*
- light_temp.csv
  - dt: dd-mm-yyyy hh:mm:ss - *the combination of date and time; this column can be left empty, because the date and time are combined in R*
  - par: x - *photosynthetic active radiation in µmol/m<sup>2</sup>/s*
  - temp: x - *temperature in Celcius*
  - date: dd-mm-yyyy - *date of the measurement*
  - time: hh:mm:ss - *time of the measurement*
- temp.csv - *this is an additional dataset in case the measurements of the PAR and temperature had different frequencies; in this case, the temperature had a higher frequency compared to the PAR measurements*
- licor.data - *the data from the Trace Gas Analyzer*

### Additional script notes

The [script](https://github.com/psychochemist/Calculation-of-CO2-CH4-fluxes/blob/main/flux.R) contains descriptive notes. Additional data required to run the script are:
- time constant in seconds (in this case, *time_constant*, line: 41)
- tube diameter in cm (in this case *tubeD*, line: 138)
- air pressure of the day when the measurements were taken (in this case *pressure_day*, line: 169) 

It has to be mentioned that in order to run the script it requires certain packages, including [FluxCalR](https://github.com/junbinzhao/FluxCalR). Therefore, there are  two  methods for installation included into the script (they are commented out, lines: 8-15). Try installing the packages with one of the given methods. As soon as it finishes installation, the script starts. 

Sometimes the script has to be run again after installation of the packages to load the packages properly. Keep in mind that it takes some time for the script to complete the calculations. As a result of the script, the file "fluxes.csv" is created which contains the fluxes in µmol/m<sup>2</sup>/s and mg/m<sup>2</sup>/d, along with input data. "fluxes.csv" is uploaded as [result.csv](https://github.com/psychochemist/Calculation-of-CO2-CH4-fluxes/blob/main/result.csv) to avoid confusion.

## Reference
 - Junbin Zhao (2019). FluxCalR: a R package for calculating CO2 and CH4 fluxes from static chambers. Journal of Open Source Software, 4(43), 1751, https://doi.org/10.21105/joss.01751, [GitHub](https://github.com/junbinzhao/FluxCalR)


Sometimes after installation of the packages, the script has to be run again to load properly the packages. Keep in mind, it takes some time for script to complete the calculations. As a result of script the file "fluxes.csv" is created which contains the fluxes in  umol/m2/s and mg/m2/d, along with input data. "fluxes.csv" is uploaded as [result.csv](https://github.com/psychochemist/Calculation-of-CO2-CH4-fluxes/blob/main/result.csv) to avoid confusion.

## Reference
 - Junbin Zhao (2019). FluxCalR: a R package for calculating CO2 and CH4 fluxes from static chambers. Journal of Open Source Software, 4(43), 1751, https://doi.org/10.21105/joss.01751, [GitHub](https://github.com/junbinzhao/FluxCalR)
