function [gKern, gVarmeans, gVarcovars] = rbfVardistPsi0Gradient(rbfKern, vardist, covGrad)

% RBFARD2VARDISTPSI0GRADIENT Description
% In the same order as rbfKernExpandParam (inverseWidth, variance)
  
% VARGPLVM
gKern = zeros(1,rbfKern.nParams); 
gKern(2) = covGrad*vardist.numData;
 
gVarmeans = zeros(1,numel(vardist.means)); 
gVarcovars = zeros(1,numel(vardist.means)); 




