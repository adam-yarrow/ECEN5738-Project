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


%% Lyapunov Function
if ~isempty(P)
    zStateIdx = const.clf.errorStateIdx;
    z = simData.x(zStateIdx,:) - xr(zStateIdx,:);
    V = NaN(nTimes,1);
    for iTime = 1:numel(simData.times)
        V(iTime) = z(:,iTime)'*P*z(:,iTime);
    end

    figure('Name',sprintf('%s - Lyapunov Function',simName));
    plot(simData.times, V);
    xlabel('Time (s)');
    ylabel('V(x(t))');
    grid on;
    title(sprintf('V vs Time - %s', simName));    
end



%% Dynamic pressure
% figure('Name',sprintf('%s - Dynamic Pressure',simName));
% plot(simData.times, simData.qBar/1000);
% xlabel('Time (s)');
% ylabel('Dynamic Pressure (kPa)');
% grid on;
% title(sprintf('Qbar vs Time - %s',simName))

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


%% Debugging
figure();
ax = [];
ax(1) = subplot(4, 1, 1);
plot(simData.times, simData.debug.G11);
ylabel('G11')
grid on;

ax(2) =subplot(4, 1, 2);
plot(simData.times, simData.debug.p1);
ylabel('p1')
grid on;

ax(3) = subplot(4, 1, 3);
plot(simData.times, simData.debug.modelMismatchTerm);
ylabel('model mismatch term')
grid on;

ax(4) = subplot(4, 1, 4);
hold on;
plot(simData.times, simData.debug.y1(1,:));
plot(simData.times, simData.debug.y1(2,:));
plot(simData.times, simData.debug.y1(3,:));
plot(simData.times, simData.debug.y1(4,:));
legend('phi','deltaE','deltaC','slack')
ylabel('y1 terms')
grid on;

linkaxes(ax,'x');



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