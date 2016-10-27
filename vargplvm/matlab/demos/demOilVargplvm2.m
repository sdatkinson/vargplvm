% DEMOILVARGPLVM2 Run variational GPLVM on oil data.

% VARGPLVM

% Fix seeds
randn('seed', 1e6);
rand('seed', 1e6);

dataSetName = 'oil';
experimentNo = 2;
printDiagram = 1;

% load data
[Y, lbls] = lvmLoadData(dataSetName);

%%% TEMP: for fewer data
Y = Y(1:100,:); 

% training and test sets
Ntr = 0.7*floor(size(Y,1)); % 70% of the data for training  
perm = randperm(size(Y,1)); 
Ytr = Y(perm(1:Ntr),:);      lblsTr = lbls(perm(1:Ntr),:);
Yts = Y(perm(Ntr+1:end),:);  lblsTs = lbls(perm(Ntr+1:end),:);


% Set up model
options = vargplvmOptions('dtcvar');
options.kern = {'rbfard2', 'bias', 'white'};
options.numActive = 50;

options.optimiser = 'scg';
latentDim = 10;
d = size(Y, 2);

model = vargplvmCreate(latentDim, d, Ytr, options);
%
model = vargplvmParamInit(model, model.m, model.X); 
model.vardist.covars = 0.5*ones(size(model.vardist.covars)) + 0.001*randn(size(model.vardist.covars));

iters = 1000;
display = 1;

model = vargplvmOptimise(model, display, iters);

iters = 100;
display = 0;



%% Reconstruct test points

fprintf('Reconstructing test points...\n');


% 50% missing outputs from the each test point
fractionOfOutputsMissing = 0.1;
numIndPresent = round((1 - fractionOfOutputsMissing) * model.d); 
% partial reconstruction of test points
numTestPoints = size(Yts, 1);
YtsMissing = Yts;
indexP = zeros(numTestPoints, numIndPresent);
Init = zeros(numTestPoints, model.q);
Testmeans = zeros(numTestPoints, model.q);
Testcovars = zeros(numTestPoints, model.q);
Varmu = zeros(numTestPoints, model.d);
Varsigma = zeros(numTestPoints, model.d);

pb = ProgressBar(numTestPoints);
for i=1:numTestPoints
    pb = pb.Update(i);
    %
    % randomly choose which outputs are present
    permi = randperm(model.d);
    indexPresent =  permi(1:numIndPresent);
    indexMissing = setdiff(1:model.q, indexPresent);
    YtsMissing(i, indexMissing) = NaN;
    indexP(i,:) = indexPresent;
    
    % initialize the latent point using the nearest neighbour 
    % from the training data
    dst = dist2(Yts(i,indexPresent), Ytr(:,indexPresent));
    [mind, mini] = min(dst);
    
    Init(i,:) = model.vardist.means(mini,:);
    % create the variational distribtion for the test latent point
    vardistx = vardistCreate(model.vardist.means(mini,:), model.q, 'gaussian');
    vardistx.covars = 0.2*ones(size(vardistx.covars));
   
    % optimize mean and vars of the latent point 
    model.vardistx = vardistx;
    % Bad code:
%     vardistx = vargplvmOptimisePoint(model, vardistx, Yts(i,indexPresent), indexPresent, display, iters);
%     Testmeans(i,:) = vardistx.means; 
%     Testcovars(i,:) = vardistx.covars;
    % Instead, we need the "unseen" dimensions in the test point to be
    % NaNs, and the output expected was wrong
    [Testmeans(i,:), Testcovars(i,:)] = vargplvmOptimisePoint(model, ...
        vardistx, YtsMissing(i,:), display, iters);   
    
    vardistx = vardistExpandParam(vardistx, [Testmeans(i,:), ...
        Testcovars(i,:)]);
    
    % reconstruct the missing outputs
    % Mean is exactly analogous to (6.66) in PRML
    % Bad code:
%     [mu, sigma] = vargplvmPosteriorMeanVar(model, vardistx);
    [mu, sigma] = vargplvmPosteriorMeanVar(model, Testmeans(i,:), ...
        Testcovars(i,:));
    Varmu(i,:) = mu; 
    Varsigma(i,:) = sigma; 
    %
end

%%  Visualize:
numClasses = size(lbls, 2);
figure;
markerList = '^os';
% Plot training data:
dataHandle = zeros(numClasses, 1);
for i = 1:numClasses
    inThisClass = find(lblsTr(:, i));
    dataHandle(i) = plot3(model.X(inThisClass, 1), ...
        model.X(inThisClass, 2), model.X(inThisClass, 3), markerList(i));
    hold on;
end
% Plot test data:
for i = 1:numClasses
    inThisClass = find(lblsTs(:, i));
    dataHandle(i) = plot3(Testmeans(inThisClass, 1), ...
        Testmeans(inThisClass, 2), Testmeans(inThisClass, 3), ...
        markerList(i), 'color', get(dataHandle(i), 'Color'), ...
        'MarkerFaceColor', get(dataHandle(i), 'Color'));
end

axis equal;
grid on;
    


capName = dataSetName;
capName(1) = upper(capName(1));
modelType = model.type;
modelType(1) = upper(modelType(1));
save(['dem' capName modelType num2str(experimentNo) '.mat'], 'model', 'perm', 'indexP', 'Varmu', 'Varsigma');

    
