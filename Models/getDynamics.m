function [xDot] = getDynamics(x, u, const)
%{
    Gets xDot = f(x,u)
    x = [V, gamma, q, theta, h]
%}

    % Control Inputs - TODO - might just pass a function in here to execute
    % as a function of state???
    phi = u(1);
    deltaE = u(2);
    deltaC = u(3);

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
    T = getThrust(alpha, phi, const);
    [CL, CD, CM] = getAeroCoeffs(alpha, deltaE, deltaC, const);

    D = qBar.*S.*CD;
    L = qBar.*S.*CL;
    M = zT*T + qBar.*S.*CM.*cBar;
    
    % Dynamics
    xDot = zeros(const.nStates,1);
    xDot(1) = (1/m)*(T.*cos(theta - gamma) - D) - g*sin(gamma);   
    xDot(2) = (1./(m*V)).*(T.*sin(theta - gamma) + L) - g./V .* cos(gamma);
    xDot(3) = M/J;
    xDot(4) = q;
    xDot(5) = V.*sin(gamma);    
end