function [simData] = Simulation(xIC, fController, tEnd)
    %{
        xIC = initial state for simulation
        fController = function handler to a controller of the form:
            u = f(t,x), where x = state of vehicle (V, gamma, q, theta,
            height), u = [phi, deltaE, deltaC]. Using time as an option too
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

    %% Run Sim
    [~, xResults] = ode45(@(t,x) plantDynCL(t,x,fController), ...
                            simData.times, xIC);
    simData.x = xResults';    

    %% Extract Control Actions
    nTimes = numel(simData.times);
    simData.u = NaN(const.nInputs,nTimes);
    for i = 1:nTimes
        simData.u(:,i) = fController(simData.times(i), simData.x(:,i));
    end
end

%% Helpers
function xDot = plantDynCL(t, x, fController)
    %{
        Wrapper for CL dynamics to make everything smooth and continous.
        Aka "we have ZOH at home"
    %}    
    u = fController(t, x);
    % [F, G] = getFGDynamics(x);
    % xDot = F + G*u;
    xDot = getDynamics(x, u);
end