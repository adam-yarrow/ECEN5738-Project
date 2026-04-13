function Gamma = getGammaH(x, const)
    alpha = calcAlpha(x);
    k = 1;
    h = const.constraint.amax^2 - alpha^2;
    Gamma = k*h;
end