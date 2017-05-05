function correlateTemporalFactorWithResponseVariable(varIndex, resultFileName)

% resultFileName is the file containing the resulting models from the
% learning method. E.g., WISDOM-1-100-1-5-1-1.mat

% get station locations
dataFile = '../data/deseasonedMonthly_smallZscore.mat';
load(dataFile);
% get stationID, stationLat, stationLon and desYMonth
numStartStations = length(stationID);
stationInitScheme = 1;
% use the same random permutation of stations with that in the algorithm
[InitialStations, addStations] = ...
    getStationInitIndex(stationLat, stationLon, numStartStations, stationInitScheme);

stationID = stationID([InitialStations; addStations]);
stationLat = stationLat([InitialStations; addStations]);
stationLon = stationLon([InitialStations; addStations]);

numStation =  length(stationID);

% load climate indices
load('../data/desClimateIndicesZscore.mat');
indexNames = {'AOI', 'NAO', 'WPI', 'PDO',  'QBO', 'SOI'};

% load spatial factors
varNames = {'tmax', 'tmin', 'tmean', 'prcp'};

threshold = 0.3;
rng(0);
load(resultFileName);
% get bestModel stucture
temporalFactor = models.B;
factors = [temporalFactor, indicesAll'];
varData = squeeze(desYMonth(:, 1:end-1, varIndex))';

corr_TFTV = corr(factors, varData);

% count the number of stations with high correlation for each factor
highCorrStationRatio = mean(abs(corr_TFTV) > threshold, 2);
h = figure('Name', varNames{varIndex}, 'Position', [100, 100, 330, 150]);
bar(highCorrStationRatio);
ax = gca;
ax.XTickLabel = {'Factor 1', 'Factor 2', 'Factor 3', 'Factor 4', 'Factor 5', indexNames{:}};
ax.XTickLabelRotation = 90;
set(h,'PaperPositionMode', 'auto');
print(h, ['TemporalFactorVSClimateIndexStationRatio-' varNames{varIndex}], '-depsc');
saveas(h, ['TemporalFactorVSClimateIndexStationRatio-' varNames{varIndex} '.fig']);

% save('correlateTemporalFactorWithResponseVariable.mat', 'highCorrStationRatio', 'threshold', 'corr_TFTV');
