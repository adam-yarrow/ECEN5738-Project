function [T] = getThrust(alpha, phiCmd, const)
%{
    Generates thrust as a function of alpha, phi. Both in rad
%} 
    
    % clamp phi to valid range
    phi = max(0.0, min(phiCmd,1.2)); % Saturation
    
    % Thrusting hard
    beta = const.thrust.beta;
    CT_alpha3 = beta(1)*phi + beta(2);
    CT_alpha2 = beta(3)*phi + beta(4);
    CT_alpha = beta(5)*phi + beta(6);
    CT_0 = beta(7)*phi + beta(8);

    T = CT_alpha3.*alpha.^3 + CT_alpha2.*alpha.^2 + CT_alpha.*alpha + CT_0;

    if const.thrust.fDisableEngine
        T = 0;
    end
end

