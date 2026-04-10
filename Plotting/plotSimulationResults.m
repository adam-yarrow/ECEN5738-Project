function plotSimulationResults(simData,simName)
%{
    Plots the simulation response.
%}

const = ModelParams();

%% States
% TODO add regulation plots
figure('Name',sprintf('%s - states',simName));
hStates = [];
for iState = 1:const.nStates
    hStates(end+1) = subplot(2,3,iState);
    plotState(simData.times, simData.x(iState,:), ...
        const.stateNames{iState}, const.statePlottingUnits{iState},...
        const.statePlottingSF(iState));
end

% Alpha
hStates(end+1) = subplot(2,3,6);
plotState(simData.times, calcAlpha(simData.x), 'Alpha', 'deg', rad2deg(1));

linkaxes(hStates,'x');
sgtitle(sprintf('States vs Time - %s', simName))


%% Control Inputs
figure('Name',sprintf('%s - control inputs',simName));
hInputs = [];
for iInput = 1:const.nInputs
    hInputs(end+1) = subplot(1,const.nInputs,iInput);
    plotState(simData.times, simData.u(iInput,:), const.inputNames{iInput},...
                const.inputPlottingUnits{iInput}, const.inputPlottingSF(iInput));
end
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

function plotState(t,data,stateName,stateUnits,SF)
    plot(t,data*SF);
    xlabel('Time (s)');
    ylabel(sprintf('%s (%s)', stateName, stateUnits));
    grid on;    
end