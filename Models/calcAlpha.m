function [alpha] = calcAlpha(x)
    % Assuming x = 5 x N
    alpha = x(4,:) - x(2,:);
end