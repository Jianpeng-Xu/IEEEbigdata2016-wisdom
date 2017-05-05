Description of data:
1. The data used in this work is in folder ../data. 
2. There are two files in data file. 
2.1 One is desClimateIndicesZscore.mat. This contains 12 known climate indices mentioned in the paper. These indices have been deseaonalized and standarized. 
2.2 The other one is deseaonedMonthly_smallZscore.mat. This contains the following variables:
--- desXMonth: deseasonalized and standarized predictors
--- desYMonth: deseaonalized and standarized response variables
--- responseNames: name of response variables
--- stationCountry: list of countries of the station locates
--- stationId
--- stationLat
--- stationLon
--- variableNames

Description of codes:
--- main.m: This is the file that you can run WISDOM with proper settings.
--- main_NoIncrementalSpace: This is the file that you can run WISDOM without incremental over space. Error on the initial 100 stations are reported. 
--- PlotSpatialFactorOnWorldMap.m: This is the file that you can plot the spatial factors on a world map.
--- wisdom_incremental_sparsa_space.m: This file solves the optimization for WISDOM with incremental over space.
--- wisdom_incremental_sparsa_time_preUpdate.m and wisdom_incremental_sparsa_time_postUpdate.m: these two files are for WISDOM with incremental over time. See main.m for the detail of how these two files are used. 
--- CorrelateTemporalFactorWithClimateIndex.m: This file is to plot the correlation between temporal factors with climate indices.
--- correlateTemporalFactorWithResponseVariable.m: This file is to plot the correlation between temporal factors with response variables. 

Other codes are to support the optimization for WISDOM, including the codes under folder 'private'.
