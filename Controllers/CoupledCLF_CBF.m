function [u, delta, mode, G11, p1, modelMismatchTerm, y1] = CoupledCLF_CBF(t, x, const, refTrajFunc, P, fCBFactive)
    %{
        Coupling CLF and CBF using KKT from paper to see how it behaves.

        refTrajFunc = function that returns x_r(t) and x_rDot(t) at a given time
        P = solution from ARE for lyap function
        fCBFactive = flag to enable/disable CBF constraints

        Z is the error rel to ref traj
        P needs to match the size of the number of active controller error
        states in ModelParams.
    %}
    %% Get Terms
    x = x([1,2,3,4,5]);
    zStatesIdx = const.clf.errorStateIdx;

    [xr, xrDot] = refTrajFunc(t);
    xrDot = xrDot(zStatesIdx);
  
    z = x(zStatesIdx) - xr(zStatesIdx);
   
    [LfV, LgV] = calcCLFLieDerivs(x, z, xrDot, P,  const);

    Lfh = getLfh(x, const);
    Lgh = getLgh(x, const);

    % CLF Terms
    V = z' * P * z;
   
    eps = const.clf.eps;
    modelMismatchTerm = getModelMismatchTerm(const, x, z, P);

    %% Define KKT terms
    % CLF Terms w/o CBF
    y1 = [LgV -1]'; % -1 is for the relaxation term
    p1 = (-LfV - eps*V - modelMismatchTerm);
    
    % Add CBF constraints
    if fCBFactive  
        Gamma = getGammaH(x,const); % Kappa function constraint on h
        y2 = [-Lgh; 0];
        p2 = (Lfh + Gamma);

        % KKT Solution
        G = getG(y1,y2,const);
        G11 = G(1,1);
        [lambda1, lambda2, mode] = solveLambdaKKT(G, p1, p2);
        
    else
        lambda2 = 0; % CBF
        y2 = zeros(4,1);
        G11 = y1'*y1;
        if G11 == 0
            lambda1 = 0;
        else
            lambda1 = omegaFunc(-p1)/(y1'*y1);
        end
        %% TODO - does this make sense if we don't use the slack var?
    end    
    
    % Extract Optimal u
    uStar = -lambda1 * y1 - lambda2 * y2;
    u = uStar(1:3);
    delta = uStar(4);

    %% Control Saturation
    u = saturateControl(u);

end

function u = saturateControl(u)
    if abs(u(2)) > deg2rad(30)
        u(2) = deg2rad(30)*sign(u(2));
    end

    if abs(u(3)) > deg2rad(30)
        u(3) = deg2rad(30)*sign(u(3));
    end

    if (u(1) > 1.2)
        u(1) = 1.2;
    elseif (u(1) < 0)
        u(1) = 0;
    end
end

%% Supporting Function
function [lambda1, lambda2, mode] = solveLambdaKKT(G, p1, p2)
    gCondNum = rcond(G);
    if -G(1,2)*omegaFunc(-p2) - G(2,2)*p1 < 0
        mode = 1;
        % lambda1 = 0 (only CBF active)
        lambda1 = 0;
        lambda2 = omegaFunc(-p2)/G(2,2);
    elseif -G(2,1)*omegaFunc(-p1) - G(1,1)*p2 < 0
        % lambda2 = 0 (only CLF active)
        lambda1 = omegaFunc(-p1)/G(1,1);
        lambda2 = 0;   
        mode = 2;
    else
        % Both active
        lambda = [omegaFunc(G(1,2)*p2 - G(2,2)*p1);
                  omegaFunc(G(2,1)*p1 - G(1,1)*p2)] ./ det(G); % Solve linear system
        lambda1 = lambda(1);
        lambda2 = lambda(2);
        mode = 3;
    end
end

function G = getG(y1,y2,const)
    r_u = const.clf.controlPenalty;
    slack_penalty = const.clf.slackPenalty;
    Hinv = diag([1./r_u; 1/slack_penalty]);
    G11 = y1'*Hinv*y1;
    G12 = y1'*Hinv*y2;
    G21 = y2'*Hinv*y1;
    G22 = y2'*Hinv*y2;
    G = [G11 G12; G21 G22];
end

function rOut = omegaFunc(r)
    if r >=0
        rOut = r;
    else
        rOut = 0;
    end    
end