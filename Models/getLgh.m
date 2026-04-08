function Lgh = getLgh(x)
%{
    Gets the Lie derivative of h with respect to g
%}
   [F, G] = getFGDynamics(x);
   alpha = calcAlpha(x);
   dh_dz = [0; 2*alpha; 0; -2*alpha; 0];
   Lgh = G' * dh_dz;
end