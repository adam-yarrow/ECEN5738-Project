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
    %% TODO - maybe replace this single call with a for loop so can pull out controller 
    %% sub states

    %% OR just have a class for the controller? - gets weird with multi-subticks?

    [~, xResults] = ode45(@(t,x) plantDynCL(t,x,fController), ...
                            simData.times, xIC);
    simData.x = xResults';    

    %% TODO - extract controller internal parameters here?
    %% OR possibly just write your own RK45 so I can log the data easier
end

%% Helpers
function xDot = plantDynCL(t, x, fController)
    %{
        Wrapper for CL dynamics to make everything smooth and continous.
        Aka "we have ZOH at home"
    %}    
    u = fController(t, x);
    xDot = getDynamics(x, u);    
end