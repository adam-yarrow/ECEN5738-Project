function [Z] = getModelMismatchTerm(const, x, z, P)
    G = [1 0 0; 
        0 1 0; 
        0 0 1; 
        0 0 0; 
        0 0 0];
    G = G(const.clf.errorStateIdx,:);
    W_deltaE = const.aero.CD_deltaESq * const.constraint.deltaEBounds(1)^2;
    W_deltaC = const.aero.CD_deltaCSq * const.constraint.deltaCBounds(1)^2;
    W = [W_deltaE; W_deltaC];

    V = x(1);
    h = x(5);
    m = const.gravimetrics.m;
    [rho, ~] = getAtmo(h, const);
    qBar = 0.5.* rho .* V.^2;
    S = const.aero.refArea;
    D_CD = qBar*S;
    l2 = [-D_CD/m -D_CD/m; 0 0; 0 0];

    % size(z)
    % size(P)
    % size(G)
    % size(l2)
    % size(W)

    Z = abs(2*(z' * P * G * l2 * W));
end