# Calculation-of-CO2-CH4-fluxes
# Application of FluxCalR package in R to calculate fluxes of carbon dioxide (CO2) and methane (CH4), based on the data aquired by from static chamber. 
## Background information about data
As a part of university project, the fluxes of CO2 and CH4 were measured with a Trace gas analyzer (LI-810 CH4/CO2/H2O Trace Gas Analyzer, LI-COR, Lincoln, NE, U.S.A; frequency: 1 Hz; precision level: 0.60 ppb for CH 4
and 3.5 ppm for CO2). The Trace Gas Analyzer was linked to a closed acrylic chamber (51 cm x 33 cm x 18 cm) which was placed above the soil.

The air temperature, atmospheric pressure and photosynthetic active radiation were aquired from weather station

All data was collected on the island Terschelling, Netherlands, as a part of student project in Radboud university.

## FluxCalR package application and metadata

The script present in this repository is supposed to show the application of FluxCalR package for calculation of fluxes, by use of metadata. 
The given metadta .csv files can be updated with new data, regarding the formating of metadata.

### Description of metadata
- start_end.csv
  - Plot: "name" - *the name of the sites where the measurements were taken*
  - L_D: "Light" or "Dark" - *the parameter of illumination which indicates whether the meauserments were done at light or dark conditions*
  - date: dd/mm/yy - *the date of the meausrment*
  - start: hhmmss - *the start point of measurement*
  - end: hhmmss - *the end point of measurement*
  - TubeL: x - *the length of tube conecting analyzer to chamber in cm*
  - SafetyC: x - *the volume of the safety chamber in cm<sup>3</sup>*
  - ChamberH: x - *the height of the chamber in cm* 
  - ChamberD: x - *the diameter of the chamber in cm*
