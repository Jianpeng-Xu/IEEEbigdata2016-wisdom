function PlotSpatialFactorOnWorldMap(varIndex, resultFileName)
% resultFileName is the file containing the resulting models from the
% learning method. E.g., WISDOM-1-100-1-5-1-1.mat

% get station locations
dataFile = '../data/deseasonedMonthly_smallZscore.mat';
load(dataFile);
% get stationID, stationLat, stationLon
numStartStations = length(stationID);
stationInitScheme = 1;
% use the same random permutation of stations with that in the algorithm
[InitialStations, addStations] = ...
    getStationInitIndex(stationLat, stationLon, numStartStations, stationInitScheme);

stationID = stationID([InitialStations; addStations]);
stationLat = stationLat([InitialStations; addStations]);
stationLon = stationLon([InitialStations; addStations]);
numStation = length(stationID);

varNames = {'tmax', 'tmin', 'tmean', 'prcp'};

myColor = jet;
myColor = myColor(1:7:end, :);
rng(0);
load(resultFileName);
% get bestModel stucture
spatioFactor = models.A;
% plot the first component
for factorIndex = 1 : size(spatioFactor, 2)
    h = figure('Name', [varNames{varIndex} '-' num2str(factorIndex)], 'Position', [100, 100, 600, 300]);
    land = shaperead('landareas.shp', 'UseGeoCoords', true);
    geoshow(land, 'FaceColor', 'white');
    hold on;
    % rescale spatioFactor
    spatioFactorLocal = spatioFactor(:, factorIndex);
    maxFactor = max(spatioFactorLocal);
    minFactor = min(spatioFactorLocal);
    spatioFactorLocal = (spatioFactorLocal - minFactor)/(maxFactor - minFactor);
    
    for stationIndex = 1 : numStation
        spatioFactorValue = spatioFactorLocal(stationIndex);
        colorIndex = ceil(spatioFactorValue/0.1 + 0.00001);
        if colorIndex > 10 colorIndex = 10; end
        geoshow(stationLat(stationIndex), stationLon(stationIndex), ...
            'DisplayType', 'point', 'Marker', '.', 'MarkerSize', 8, ...
            'Color', myColor(colorIndex,:), 'MarkerEdgeColor', 'auto');
    end
    colormap(jet);
    colorbar;
    % save the figure
    axis off;
    set(h,'PaperPositionMode', 'auto');
    print(h, ['spatialFactor-' num2str(factorIndex) '-WorldMap-' varNames{varIndex}], '-depsc');
    saveas(h, ['spatialFactor-' num2str(factorIndex) '-WorldMap-' varNames{varIndex} '.fig']);
end
