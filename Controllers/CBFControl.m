function [u,exit] = CBFControl(t, x, const)
    c = const.constraint;

    Lfh = getLfh(x, const);
    Lgh = getLgh(x, const);

    Gamma = getGammaH(x,const);

    % Minimize u'Hu + f'u
    H = [eye(3)];
    % Slack penalties
    f = [0; 0; 0];

    % A * u <= b
    A = [-Lgh'];
    b = [Lfh+Gamma];

    % lb <= u <= ub
    lb = [c.phiBounds(1); c.deltaEBounds(1); c.deltaCBounds(1)];
    ub = [c.phiBounds(2); c.deltaEBounds(2); c.deltaCBounds(2)];

    u0 = zeros(3,1);

    options = optimoptions('quadprog');
    options.Display = 'off';

    [u,~,status] = quadprog(H, f, A, b, [], [], lb, ub, u0, options);
    if status<1
        u = u0;
        exit = 1;
    else
        exit = 0;
    end
end