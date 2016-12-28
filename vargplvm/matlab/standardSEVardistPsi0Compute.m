function k0 = standardSEVardistPsi0Compute(sKern, vardist)

% STANDARDSEVARDISTPSI0COMPUTE description.
  
% VARGPLVM
  
% variational means

% dont include the jitter term (it only for the inducing matrix K_uu)

k0 = vardist.numData; 
