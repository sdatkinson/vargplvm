function [gKern, gVarmeans, gVarcovars] = standardSEVardistPsi0Gradient(sKern, vardist, covGrad)

% STANDARDSEVARDISTPSI0GRADIENT Description
  
% VARGPLVM
gKern = zeros(1,sKern.nParams); 
gKern(1) = covGrad*vardist.numData;
 
gVarmeans = zeros(1,prod(size(vardist.means))); 
gVarcovars = zeros(1,prod(size(vardist.means))); 