function [CL,CD,CM] = getAeroCoeffs(alpha,deltaE,deltaC)
    c = ModelParams('aero');

    CL = c.CL_alpha*alpha + c.CL_deltaE*deltaE + c.CL_deltaC*deltaC + c.CL_0;

    CD = c.CD_alphaSq*alpha.^2 + c.CD_alpha*alpha + ...
        c.CD_deltaE*deltaE + c.CD_deltaESq*deltaE.^2 + ...
        c.CD_deltaC*deltaC + c.CD_deltaCSq*deltaC.^2 + ...
        c.CD_0;

    CM = c.CM_alphaSq*alpha.^2 + c.CM_alpha*alpha + c.CM_deltaE*deltaE + ...
        c.CM_deltaC*deltaC + c.CM_0;
    
    % Make statically stable
    if c.fMakeStaticallyStable
        CM = -c.CM_alphaSq*alpha.^2 + -c.CM_alpha*alpha + c.CM_deltaE*deltaE + ...
            c.CM_deltaC*deltaC + c.CM_0;
    end
    
end