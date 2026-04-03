function [T] = getThrust(alpha, phi)
%{
    Generates thrust as a function of alpha, phi. Both in rad
%} 
    T = 0;
    CT_alpha3 = [];
    CT_alpha2 = [];
    CT_alpha = [];
    CT_0 = [];

    T = CT_alpha3.*alpha.^3 + CT_alpha2.*alpha.^2 + CT_alpha.*alpha + CT_0;
    
end