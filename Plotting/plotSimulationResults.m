function plotSimulationResults(simData,simName, refTrajFunc, P)
%{
    Plots the simulation response.
%}

const = ModelParams();

if nargin < 3
    refTrajFunc = [];
    P = [];
end

%% Ref Traj
if ~isempty(refTrajFunc)
    xr = refTrajFunc(simData.times);    
else
    xr = [];
end

nTimes = length(simData.times);


%% States
% TODO add regulation plots
figure('Name',sprintf('%s - states',simName));
hStates = [];
for iState = 1:const.nStates
    if ~isempty(xr)
        xrCurrent = xr(iState,:);
    else
        xrCurrent = [];
    end

    hStates(end+1) = subplot(2,3,iState);
    hold on;
    plotState(simData.times, simData.x(iState,:), ...
        const.stateNames{iState}, const.statePlottingUnits{iState},...
        const.statePlottingSF(iState), xrCurrent);
    legend();
end

% Alpha
hStates(end+1) = subplot(2,3,6);
plotState(simData.times, calcAlpha(simData.x), 'Alpha', 'deg', rad2deg(1),[]);

linkaxes(hStates,'x');
sgtitle(sprintf('States vs Time - %s', simName))

%% Lyapunov Function
if ~isempty(P)
    zStateIdx = const.clf.errorStateIdx;
    z = simData.x(zStateIdx,:) - xr(zStateIdx,:);
    V = NaN(nTimes,1);
    for iTime = 1:numel(simData.times)
        V(iTime) = z(:,iTime)'*P(zStateIdx,zStateIdx)*z(:,iTime);
    end

    figure('Name',sprintf('%s - Lyapunov Function',simName));
    plot(simData.times, V);
    xlabel('Time (s)');
    ylabel('V(x(t))');
    grid on;
    title(sprintf('V vs Time - %s', simName));    
end

%% Control Inputs
figure('Name',sprintf('%s - control inputs',simName));
hInputs = [];
for iInput = 1:const.nInputs 
    hInputs(end+1) = subplot(2,2,iInput);
    hold on;
    plotState(simData.times, simData.u(iInput,:), const.inputNames{iInput},...
                const.inputPlottingUnits{iInput}, const.inputPlottingSF(iInput),[]);
end
hInputs(end+1) = subplot(2,2,4);
plotState(simData.times, simData.slackVar(:), 'Slack Variable','-', 1, []);

linkaxes(hInputs,'x');
sgtitle(sprintf('Inputs vs Time - %s',simName));

%% Dynamic pressure
figure('Name',sprintf('%s - Dynamic Pressure',simName));
plot(simData.times, simData.qBar/1000);
xlabel('Time (s)');
ylabel('Dynamic Pressure (kPa)');
grid on;
title(sprintf('Qbar vs Time - %s',simName))

%% Anything Else?

end

function plotState(t,data,stateName,stateUnits,SF, xr)
    plot(t,data*SF,'k','DisplayName','Trajectory');

    if ~isempty(xr)
        plot(t, xr*SF,'r--','DisplayName','Reference Trajectory');
    end

    xlabel('Time (s)');
    ylabel(sprintf('%s (%s)', stateName, stateUnits));
    grid on;    

end