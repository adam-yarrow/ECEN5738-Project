function [LfV, LgV] = calcCLFLieDerivs(x, z, xDot_r, P, const)

    [f_x, g_x] = getFGDynamics(x, const);
    f_x = f_x(const.clf.errorStateIdx);
    g_x = g_x(const.clf.errorStateIdx,:);
         
    grad_V = 2 * z' * P;
    LfV = grad_V * (f_x - xDot_r); 
    LgV = grad_V * g_x;
end