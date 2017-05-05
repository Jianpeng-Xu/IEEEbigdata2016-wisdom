function main(responseIndex, numStartStations, stationInitScheme, R, lambda, eta, beta)
rng(0);

% responseIndex:
% 1 : tmax; 2: tmin; 3: tmean; 4: precip
% stationInitScheme: 1 - random initilize index, 2 - use cluster centroids
% after do a clustering method. This index is returned from a function
% called getStationInitIndex

% Useful variables:
% desXMonth: 1118 * 371 * 13
% desYMonth: 1118 * 371 * 4
dataset = 'deseasonedMonthly_smallZscore.mat';
path = '../data/';
load([path dataset]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[S, T, d] = size(desXMonth);
desYMonth = desYMonth(1:S, 1:T, :);

[InitialStations, addStations] = getStationInitIndex(stationLat, stationLon, numStartStations, stationInitScheme);

desXMonth = desXMonth([InitialStations; addStations], :, :);
desYMonth = squeeze(desYMonth([InitialStations; addStations], :, responseIndex));

TrainingSize = 120;
ValidationSize = 120;
TestingSize = T - TrainingSize - ValidationSize;


pAll = ones(S+T - numStartStations - 1, 1);
pAll(randperm(length(pAll), T-1)) = 0;
pAll = [pAll;0]; % manually set the last update is time

% run learning method
% do incremental learning.
% randomly choose whether to incremental over time or space
Y_hat = NaN(S, T);
spaceIndex = (1 : length(InitialStations))';
% Initialize regularization coefficients

MAE_valid = NaN(1, ValidationSize);
MAE_test = NaN(1, TestingSize);
MAE_test_station = NaN(S,TestingSize);


t = 0;
s = length(spaceIndex);
% randomly initialize the models
A = rand(s, R); B = rand(t, R); C = rand(d, R); W = rand(R,d); V = rand(R,d);
pIndex = 1;
while s <S || t < T
    p = pAll(pIndex);
    pIndex = pIndex + 1;
    tos = ' ';
    if p <=0.3
        tos = 'time';
    else
        tos = 'space';
    end
    
    if s >= S || t == 0
        tos = 'time';
    end
    if t >= T
        tos = 'space';
    end
    if strcmp(tos, 'time')
        % incremental over time
        %             fprintf('Incremental over time\n');
        % increase t
        t = t + 1;
        % prepare data
        X_T = squeeze(desXMonth(spaceIndex, t, :));
        Y_T = squeeze(desYMonth(spaceIndex, t));
        % update models
        %             fprintf(['update models for t + 1 = ' num2str(t) ' ']);
        % call update model method for incremental over time
        % preUpdate
        BT = wisdom_incremental_sparsa_time_preUpdate(X_T, A, C, R, lambda, beta);
        % do prediction on X_T
        Y_hat(spaceIndex,t) = (sum(X_T .* bsxfun(@plus, A * W, BT'*V),2));
        MAE_local = mean(abs(Y_hat(spaceIndex,t) - Y_T));
        % record the loss
        % if t is in validation period
        if t > TrainingSize && t <= TrainingSize + ValidationSize
            MAE_valid(t-TrainingSize) = MAE_local;
        end
        % if t is in testing period
        if t > TrainingSize + ValidationSize
            MAE_test(t-TrainingSize - ValidationSize) = MAE_local;
            MAE_test_station(spaceIndex, t - TrainingSize - ValidationSize) = abs(Y_hat(spaceIndex,t) - Y_T);
        end
        
        %             fprintf(['MAE = ' num2str(MAE_local) ', lambda = ' num2str(lambda_local)...
        %                 ', eta = ' num2str(eta_local) ', beta = ' num2str(beta_local) '\n']);
        % postUpdate
        [W, V, A, BT, C] = wisdom_incremental_sparsa_time_postUpdate...
            (X_T, Y_T, W, V, A, C, lambda, eta, beta, R);
        B = [B; BT'];
    elseif strcmp(tos, 'space')
        % incremental over space
        %             fprintf('Incremental over space\n');
        % incease s
        s = s + 1;
        % prepare data
        newStationIndex = s;
        spaceIndex = [spaceIndex; newStationIndex];
        X_S =reshape( desXMonth(newStationIndex, 1:t, :), [], d);
        Y_S = reshape(desYMonth(newStationIndex, 1:t), [], 1);
        % update models
        %             fprintf(['update models for s + 1 = ' num2str(s) '\n']);
        % call update modele method for incremental over space
        [W, V, AS, B, C] = wisdom_incremental_sparsa_space...
            (X_S, Y_S, W, V, B, C, lambda, eta, beta, R);
        A = [A; AS'];
    end
    
end
% record the models
models.A = A; models.B = B; models.C = C; models.W = W; models.V = V;

% compute MAE
MAE_ALL = (nanmean(abs(Y_hat - desYMonth), 2))';
averageMAE_valid = nanmean(MAE_valid, 2);

save(['WISDOM-' num2str(responseIndex) '-' num2str(numStartStations) '-' num2str(stationInitScheme) '-' num2str(R) '-' num2str(lambda) '-' num2str(eta) '-' num2str(beta) '.mat'], ...
    'Y_hat', 'MAE_ALL', 'models', ...
    'lambda', 'eta', 'beta', 'R');