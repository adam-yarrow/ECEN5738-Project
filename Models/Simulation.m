function [simData] = Simulation(xIC, fController, tEnd)
    %{
        xIC = initial state for simulation
        fController = function handler to a controller of the form:
            u = f(t,x,const), where x = state of vehicle (V, gamma, q, theta,
            height), u = [phi, deltaE, deltaC], const=ModelParams(). Using time as an option too
            in case trying to track a reference trajectory embedded in
            fController.
        tEnd = End time (s)
    %}

    const = ModelParams();

    %% Warnings
    if const.thrust.fDisableEngine || const.aero.fMakeStaticallyStable
        warning('Naughty naughty, you are playing on easy mode. Build a better controller.')
    end

    %% Data Packaging
    simData = struct();
    simData.times = 0:const.dT:tEnd;
    nTimes = numel(simData.times);

    %% Run Sim
    xResults = zeros(nTimes, const.nStates);
    if const.continuous == true
        [~, xResults] = ode45(@(t,x) plantDynCL(t,x,fController, const), ...
                                simData.times, xIC);
    else
        xResults(1,:) = xIC';
        xk = xIC;
        u = zeros(3,1);
        for k=2:nTimes
            tkprev = simData.times(k-1);
            tk = simData.times(k);
            [u,~] = fController(tkprev, xk, const);
            [~, xtraj] = ode45(@(t,x) getDynamics(x, u, const), ...
                                    [0,const.dT], xk);
            disp(tk)
            xk = xtraj(end,:)';
            xResults(k,:) = xk';
        end
    end
    simData.x = xResults';   

    %% Extract Control Actions
    simData.u = NaN(const.nInputs,nTimes);
    for i = 1:nTimes
        [simData.u(:,i),~] = fController(simData.times(i), simData.x(:,i), const);
    end
end

%% Helpers
function xDot = plantDynCL(t, x, fController, const)
    %{
        Wrapper for CL dynamics to make everything smooth and continous.
        Aka "we have ZOH at home"
    %}    
    [u,~] = fController(t, x, const);
    % [F, G] = getFGDynamics(x);
    % xDot = F + G*u;
    xDot = getDynamics(x, u, const);
end