function [rho, a] = getAtmo(h)
    [~,a,~,rho] = atmosisa(h,extended=true);
    % TODO - might change this to an exp approx near the reference height
    % like the paper???
end