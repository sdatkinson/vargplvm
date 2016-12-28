function k0 = rbfVardistPsi0Compute(rbfKern, vardist)

% RBFVARDISTPSI0COMPUTE description.
  
% VARGPLVM
  
% variational means

k0 = vardist.numData*rbfKern.variance; 


