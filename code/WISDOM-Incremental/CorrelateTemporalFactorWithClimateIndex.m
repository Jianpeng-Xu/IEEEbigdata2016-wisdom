function CorrelateTemporalFactorWithClimateIndex(varIndex, resultFileName)
% resultFileName is the file containing the resulting models from the
% learning method. E.g., WISDOM-1-100-1-5-1-1.mat

varNames = {'tmax', 'tmin', 'tmean', 'prcp'};

load('../data/desClimateIndicesZscore.mat');
% get indicesAll
indicesAll = indicesAll';
numIndex = size(indicesAll, 2);


load(resultFileName);
% get bestModel stucture
temporalFactor = models.B;
numFactor = size(temporalFactor, 2);
RHO = corr(temporalFactor, indicesAll);
% plot the heatmap for each variable
h = figure('Name', varNames{varIndex}, 'Position', [100, 100, 300, 120]);
imagesc(RHO);
%    colormap(contrast(RHO_local));
ch = colorbar;
set(ch, 'YTick', [-0.4:0.2:0.6]);
ax = gca;
ax.XTick = 1 : numIndex;
ax.XTickLabel = {'AOI', 'NAO', 'WPI',...
    'PDO', 'QBO', 'SOI'};
ax.XTickLabelRotation = 90;
xlim([0 numIndex]);
ax.YTick =  1 : numFactor;

set(h,'PaperPositionMode', 'auto');
print(h, ['TemporalFactorVSClimateIndex-' varNames{varIndex}], '-depsc');
saveas(h, ['TemporalFactorVSClimateIndex-' varNames{varIndex} '.fig']);

