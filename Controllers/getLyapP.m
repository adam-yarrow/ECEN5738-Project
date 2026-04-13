function [P] = getLyapP(Q_ARE, R_ARE)
    F = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0];
    G = [1 0 0; 0 1 0; 0 0 1; 0 0 0];  
    [P, ~, ~] = care(F, G, Q_ARE, R_ARE);
end