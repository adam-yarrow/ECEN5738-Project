function [u] = CBFControl(t, x, const)
    c = const.constraint;

    Lfh = getLfh(x, const);
    Lgh = getLgh(x, const);

    alpha = calcAlpha(x);
    k = 1;
    h = c.amax^2 - alpha^2;
    Gamma = k*h;

    % Constraints
    % umulti * u <= leqbounds
    umulti = [-Lgh'];
    leqbounds = [Lfh+Gamma];

    options = optimoptions('quadprog', 'Display', 'off');
    [u,~,status] = quadprog(eye(3), zeros(3,1), umulti, leqbounds, [], [], [], [], [], options);
    if status<1
        u = zeros(3,1);
    end
    % Saturation
    u(1) = max(0.0, min(u(1),c.phimax));
end