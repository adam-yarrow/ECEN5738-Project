function [rho, a] = getAtmo(h, const)
    atmoParam = const.atmo;
    if atmoParam.fUseSimpleAtmo
        rho = atmoParam.rho0 * exp(-(h - atmoParam.h0)/atmoParam.hs);
        a = []; % not used
    else
        [~,a,~,rho] = atmosisa(h,extended=true);
    end
end