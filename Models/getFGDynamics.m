function [xDot_f, xDot_g] = getFGDynamics(x)
%{
    Gets f(x) and g(x) from xDot = f(x)+g(x)u
    x = [V, gamma, q, theta, h]
%}
    const = ModelParams();

    % States and Derived params
    V = x(1);
    gamma = x(2);
    q = x(3);
    theta = x(4);
    h = x(5);
    alpha = calcAlpha(x);

    % Sys Params
    m = const.gravimetrics.m;
    J = const.gravimetrics.Iyy;
    g = const.g;

    cBar = const.aero.refLength;
    S = const.aero.refArea;
    zT = const.thrust.zOffset;

    % Get Dynamic Pressure
    [rho, ~] = getAtmo(h);
    qBar = 0.5.* rho .* V.^2; % Pa

    % Get External Forces
    beta = ModelParams('thrust','beta');
    CT_alpha3_f = beta(2);
    CT_alpha3_g_phi = beta(1);
    CT_alpha2_f = beta(4);
    CT_alpha2_g_phi = beta(3);
    CT_alpha_f = beta(6);
    CT_alpha_g_phi = beta(5);
    CT_0_f = beta(8);
    CT_0_g_phi = beta(7);

    T_f = CT_alpha3_f.*alpha.^3 + CT_alpha2_f.*alpha.^2 + CT_alpha_f.*alpha + CT_0_f;
    T_g_phi = CT_alpha3_g_phi.*alpha.^3 + CT_alpha2_g_phi.*alpha.^2 + CT_alpha_g_phi.*alpha + CT_0_g_phi;

    if ModelParams('thrust','fDisableEngine')
        T_f = 0;
        T_g_phi = 0;
    end

    c = ModelParams('aero');

    CL_f = c.CL_alpha*alpha + c.CL_0;
    CL_g_deltaE = c.CL_deltaE;
    CL_g_deltaC = c.CL_deltaC;

    CD_f = c.CD_alphaSq*alpha.^2 + c.CD_alpha*alpha + c.CD_0;
    CD_g_deltaE = c.CD_deltaE; % Disregard + c.CD_deltaESq*deltaE
    CD_g_deltaC = c.CD_deltaC; % Disregard + c.CD_deltaCSq*deltaC

    CM_f = c.CM_alphaSq*alpha.^2 + c.CM_alpha*alpha + c.CM_0;
    CM_g_deltaE = c.CM_deltaE;
    CM_g_deltaC = c.CM_deltaC;

    if c.fMakeStaticallyStable
        CM_f = -c.CM_alphaSq*alpha.^2 + -c.CM_alpha*alpha + c.CM_0;
        CM_g_deltaE = c.CM_deltaE;
        CM_g_deltaC = c.CM_deltaC;
    end

    D_f = qBar.*S.*CD_f;
    D_g_deltaE = qBar.*S.*CD_g_deltaE;
    D_g_deltaC = qBar.*S.*CD_g_deltaC;
    L_f = qBar.*S.*CL_f;
    L_g_deltaE = qBar.*S.*CL_g_deltaE;
    L_g_deltaC = qBar.*S.*CL_g_deltaC;
    M_f = zT*T_f + qBar.*S.*CM_f.*cBar;
    M_g_phi = zT*T_g_phi;
    M_g_deltaE = qBar.*S.*CM_g_deltaE.*cBar;
    M_g_deltaC = qBar.*S.*CM_g_deltaC.*cBar;
    
    % Dynamics
    xDot_f = zeros(const.nStates,1);
    xDot_f(1) = (1/m)*(T_f.*cos(theta - gamma) - D_f) - g*sin(gamma);   
    xDot_f(2) = (1./(m*V)).*(T_f.*sin(theta - gamma) + L_f) - g./V .* cos(gamma);
    xDot_f(3) = M_f/J;
    xDot_f(4) = q;
    xDot_f(5) = V.*sin(gamma);

    xDot_g = zeros(const.nStates,const.nInputs);
    xDot_g(1,1) = (1/m)*T_g_phi.*cos(theta - gamma);
    xDot_g(1,2) = (1/m)*-D_g_deltaE;
    xDot_g(1,3) = (1/m)*-D_g_deltaC;
    xDot_g(2,1) = (1./(m*V)).*T_g_phi.*sin(theta - gamma);
    xDot_g(2,2) = (1./(m*V)).*L_g_deltaE;
    xDot_g(2,3) = (1./(m*V)).*L_g_deltaC;
    xDot_g(3,1) = M_g_phi/J;
    xDot_g(3,2) = M_g_deltaE/J;
    xDot_g(3,3) = M_g_deltaC/J;
    xDot_g(4,1) = 0;
    xDot_g(4,2) = 0;
    xDot_g(4,3) = 0;
    xDot_g(5,1) = 0; 
    xDot_g(5,2) = 0;
    xDot_g(5,3) = 0;
end