function PlotSpatialFactorClusterOnWorldMap(varIndex, resultFileName)
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

% load spatial factors
varNames = {'tmax', 'tmin', 'tmean', 'prcp'};

clusterNum = 10;
    rng(0);
    load(resultFileName);
    % get bestModel stucture
    spatioFactor = models.A;
    % perform clustering method on spatioFactor
    idx = kmeans(spatioFactor, clusterNum, 'Start', 'cluster'); % each row is the cluster assignment for each location
    % Plot the stations for each of the cluster with each color
    % load the worldmap
    h = figure('Name', varNames{varIndex}, 'Position', [100, 100, 600, 300]);
%     title(['Stations with good performance for ' methodList{j} ', ' responseNames{i}]);
%     worldmap('World');
    land = shaperead('landareas.shp', 'UseGeoCoords', true);
    geoshow(land, 'FaceColor', 'white');
    hold on;
%     geoshow(stationLat(goodStationIndex), stationLon(goodStationIndex), 'DisplayType', 'point',  'Marker', '.', 'Color', 'blue', 'MarkerEdgeColor', 'auto');
    for i = 1 : clusterNum
        geoshow(stationLat(idx==i), stationLon(idx==i), 'DisplayType', 'point', 'Marker', '.', 'MarkerSize', 8, 'Color', rand(1,3), 'MarkerEdgeColor', 'auto');
    end
    % save the figure
    axis off;
    set(h,'PaperPositionMode', 'auto');
    print(h, ['spatialFactorClusterWorldMap-' varNames{varIndex}], '-depsc');
    saveas(h, ['spatialFactorClusterWorldMap-' varNames{varIndex} '.fig']);

