function [LfV, LgV] = calcCLFLieDerivs(x, x_r, xDot_r, P, const)

    [f_x, g_x] = getFGDynamics(x, const);
    f_x_4 = f_x(1:4);
    g_x_4 = g_x(1:4, :);
    
    z = x(1:4) - x_r(1:4);
    
    grad_V = 2 * z' * P;
    LfV = grad_V * (f_x_4 - xDot_r(1:4)); 
    LgV = grad_V * g_x_4;
end