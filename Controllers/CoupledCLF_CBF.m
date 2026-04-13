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
    [xr, xrDot] = refTrajFunc(t);

    % NOTE: These only done for the first 4 states (ignoring height state
    % for now)
    [LfV, LgV] = calcCLFLieDerivs(x, xr, xrDot, P,  const);

    Lfh = getLfh(x, const);
    Lgh = getLgh(x, const);

    % CLF Terms
    zStatesIdx = const.clf.errorStateIdx;
    z = x(zStatesIdx) - xr(zStatesIdx);
    V = z' * P * z;

    eps = const.clf.eps;

    %% TODO: Add abs(2*z'*P*G*l2*W)
    %% NEED TO WORK OUT WHAT W and L2 correspond to
    modelMismatchTerm = 0; 

    %% Define KKT terms
    % CLF Terms w/o CBF
    y1 = [LgV -1]'; % -1 is for the relaxation term
    p1 = 2*(-LfV - eps*V - modelMismatchTerm); % Scale factor of 2 due to lyapunov deriv
    y2 = zeros(4,1);
    p2 = 0;

    % Add CBF constraints
    if fCBFactive  
        Gamma = getGammaH(x,const); % Kappa function constraint on h
        y2 = [-Lgh; 0];
        p2 = 2*(Lfh + Gamma); %% TODO - check if scale factor of 2 is appropriate here and on p1?
    else

        error('Need to better formulate the problem for CBF off')
        %% NOTE: Get a singlularity here with G inv
    end

    %% KKT Solutions
    G = getG(y1,y2);
    [lambda1, lambda2] = solveLambdaKKT(G, p1, p2);
    
    % Extract Optimal u
    uStar = -lambda1/2 * y1 - lambda2/2 * y2;
    u = uStar(1:3);
    delta = uStar(4);
end

%% Supporting Function
function [lambda1, lambda2] = solveLambdaKKT(G, p1, p2)
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
        lambda = G\[p1;p2]; % Solve linear system
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