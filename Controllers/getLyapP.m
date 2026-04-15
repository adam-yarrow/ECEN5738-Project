function [P] = getLyapP(Q_ARE, R_ARE, Vref, const)
    F = [0 0 0 0 0; 
        0 0 0 0 0; 
        0 0 0 0 0; 
        0 0 1 0 0;
        0 Vref 0 0 0];
    G = [1 0 0; 
        0 1 0;
        0 0 1; 
        0 0 0;
        0 0 0];  

    F = F(const.clf.errorStateIdx, const.clf.errorStateIdx);
    G = G(const.clf.errorStateIdx, :);
    [P, ~, ~] = care(F, G, Q_ARE, R_ARE);
end