function [u, delta] = CoupledCLF_CBF(t, x, const, refTrajFunc, P, fCBFactive)
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
    zStatesIdx = const.clf.errorStateIdx;

    [xr, xrDot] = refTrajFunc(t);
    xrDot = xrDot(zStatesIdx);
    P = P(zStatesIdx, zStatesIdx);
  
    z = x(zStatesIdx) - xr(zStatesIdx);
    [LfV, LgV] = calcCLFLieDerivs(x, z, xrDot, P,  const);

    Lfh = getLfh(x, const);
    Lgh = getLgh(x, const);

    % CLF Terms
    V = z' * P * z;

    eps = const.clf.eps;

    %% TODO: Add abs(2*z'*P*G*l2*W)
    %% NEED TO WORK OUT WHAT W and L2 correspond to
    modelMismatchTerm = 0; 

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
        G = getG(y1,y2);
        [lambda1, lambda2] = solveLambdaKKT(G, p1, p2);
        
    else
        %% TODO - maybe just convert this to PMN controller for now???


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
function [lambda1, lambda2] = solveLambdaKKT(G, p1, p2)
    gCondNum = rcond(G);
    if -G(1,2)*omegaFunc(-p2) - G(2,2)*p1 < 0
        % lambda1 = 0 (only CBF active)
        lambda1 = 0;
        lambda2 = omegaFunc(-p1)/G(2,2);
    elseif -G(2,1)*omegaFunc(-p1) - G(1,1)*p2 < 0
        % lambda2 = 0 (only CLF active)
        lambda1 = omegaFunc(-p1)/G(1,1);
        lambda2 = 0;   
    else
        % Both active
        lambda = pinv(G)*[p1;p2]; % Solve linear system
        lambda1 = lambda(1);
        lambda2 = lambda(2);
    end
end

function G = getG(y1,y2)
    G11 = y1'*y1;
    G12 = y1'*y2;
    G21 = y2'*y1;
    G22 = y2'*y2;
    G = [G11 G12; G21 G22];
end

function rOut = omegaFunc(r)
    if r >=0
        rOut = r;
    else
        rOut = 0;
    end    
end