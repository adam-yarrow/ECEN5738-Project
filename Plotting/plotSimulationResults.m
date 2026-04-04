function plotSimulationResults(simData,simName)
%{
    Plots the simulation response.
%}

const = ModelParams();

%% States
% TODO add regulation plots
figure('Name',sprintf('%s - states',simName));
for iState = 1:const.nStates
    subplot(2,3,iState)
    plotState(simData.times, simData.x(iState,:), ...
        const.stateNames{iState}, const.statePlottingUnits{iState},...
        const.statePlottingSF(iState));
end

% Alpha
subplot(2,3,6);
plotState(simData.times, calcAlpha(simData.x), 'Alpha', 'deg', rad2deg(1));

subtitle(sprintf('States vs Time - %s', simName))


%% Control Inputs
%% TODO - either re-run states through controller, or save this with the class approach


%% Controller Internals??

end

function plotState(t,data,stateName,stateUnits,SF)
    plot(t,data*SF);
    xlabel('Time (s)');
    ylabel(sprintf('%s (%s)', stateName, stateUnits));
    grid on;    
end