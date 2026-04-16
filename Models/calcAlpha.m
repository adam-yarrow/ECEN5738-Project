function [alpha] = calcAlpha(x)
    % Assuming x = 5 x N
    idxr = [0 -1 0 1 0];
    alpha = idxr*x;
end