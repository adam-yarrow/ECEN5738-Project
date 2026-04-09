function Lfh = getLfh(x, const)
%{
    Gets the Lie derivative of h with respect to f
%}
   [F, G] = getFGDynamics(x, const);
   alpha = calcAlpha(x);
   dh_dz = [0; 2*alpha; 0; -2*alpha; 0];
   Lfh = F' * dh_dz;
end