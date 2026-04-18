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
    xResults = zeros(nTimes, size(xIC,1));
    if const.continuous == true
        options = odeset('OutputFcn',@ode45OutputFunc,'AbsTol',1E-10);
        % [~, xResults] = ode45(@(t,x) plantDynCL(t,x,fController, const), ...
        %                         simData.times, xIC, options);

        [~, xResults] = RK4(@(t,x) plantDynCL(t,x,fController, const),...
                            [simData.times(1), simData.times(end)], xIC, const.dT);
    else
        xResults(1,:) = xIC';
        xk = xIC;
        u = zeros(3,1);
        for k=2:nTimes
            tkprev = simData.times(k-1);
            tk = simData.times(k);
            [u,~] = fController(tkprev, xk, const);
            [~, xtraj] = RK4(@(t,x) getDynamics(x,u,const), ...
                                [0, const.dT], xk, const.dT);
            % [~, xtraj] = ode45(@(t,x) getDynamics(x, u, const), ...
            %                         [0,const.dT], xk);
            xk = xtraj(end,:)';
            
            disp(tk);
            xResults(k,:) = xk';
        end
    end
    simData.x = xResults';   

    %% Extract Control Actions and other Useful Quantities
    simData.u = NaN(const.nInputs,nTimes);
    simData.slackVar = NaN(nTimes,1);
    simData.qBar = NaN(nTimes,1);
    simData.controlMode = NaN(nTimes,1);
    simData.debug.G11 = NaN(nTimes, 1);
    simData.debug.p1 = NaN(nTimes,1);
    simData.debug.modelMismatchTerm = NaN(nTimes,1);
    simData.debug.y1 = NaN(4,nTimes);

    for i = 1:nTimes
        % Control Input
        [simData.u(:,i),simData.slackVar(i), simData.controlMode(i),...
            simData.debug.G11(i), simData.debug.p1(i),...
            simData.debug.modelMismatchTerm(i), simData.debug.y1(:,i)] = ...
            fController(simData.times(i), ...
                simData.x(:,i), const);

        % Qbar
        rho = getAtmo(simData.x(end,i), const);
        simData.qBar(i) = 0.5*rho*simData.x(1,i)^2;
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