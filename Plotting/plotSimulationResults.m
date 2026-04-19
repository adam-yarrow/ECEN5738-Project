function plotSimulationResults(simDataCell,simNames, refTrajFunc, P)
%{
    Plots the simulation response.
    simData can be a cell array
%}

const = ModelParams();

if nargin < 3
    refTrajFunc = [];
    P = [];
end

%% Ref Traj
if ~isempty(refTrajFunc)
    xr = refTrajFunc(simDataCell{1}.times);    
else
    xr = [];
end

nTraj = length(simDataCell);


%% Lyapunov Function
if ~isempty(P)

    figure('Name',sprintf('Lyapunov Function'));
    hold on;
    for iTraj = 1:nTraj
        simData = simDataCell{iTraj};
        nTimes = length(simData.times);
    
        zStateIdx = const.clf.errorStateIdx;
        z = simData.x(zStateIdx,:) - xr(zStateIdx,:);
        V = NaN(nTimes,1);
        for iTime = 1:numel(simData.times)
            V(iTime) = z(:,iTime)'*P*z(:,iTime);
        end    
        plot(simData.times, V,'DisplayName',simNames{iTraj},'LineWidth',1.5);
    end
    legend();
    xlabel('Time (s)');
    ylabel('V(x(t))');
    grid on;
    title(sprintf('V vs Time'));    
    ax = gca;
    ax.LineWidth = 2;  % Thicker axes
    ax.FontSize = 12;
end



%% Dynamic pressure
figure('Name',sprintf('Dynamic Pressure'));
hold on;
for iTraj = 1:nTraj
    simData = simDataCell{iTraj};
    plot(simData.times, simData.qBar/1000,'DisplayName',simNames{iTraj},'LineWidth',1.5);
end
legend();
xlabel('Time (s)');
ylabel('Dynamic Pressure (kPa)');
grid on;
title(sprintf('Qbar vs Time'));
ax = gca;
ax.LineWidth = 2;  % Thicker axes
ax.FontSize = 12;

%% Control Inputs
figure('Name',sprintf('Control inputs'));
hInputs = [];
for iInput = 1:const.nInputs 
    hInputs(end+1) = subplot(2,2,iInput);
    hold on;
    plotState(simDataCell, 'u', iInput, simNames, const.inputNames{iInput},...
                const.inputPlottingUnits{iInput}, const.inputPlottingSF(iInput),[]);
end
hInputs(end+1) = subplot(2,2,4);
hold on;
for iTraj = 1:numel(simDataCell)
    simData = simDataCell{iTraj};
    data = simData.slackVar;
    t = simData.times;
    plot(t,data,'DisplayName',simNames{iTraj},'LineWidth',1.5);
end
xlabel('Time (s)');
ylabel(sprintf('%s (%s)', 'Slack Variable', '-'));
grid on;   
legend();
ax = gca;
ax.LineWidth = 2;  % Thicker axes
ax.FontSize = 12;

linkaxes(hInputs,'x');
sgtitle(sprintf('Inputs vs Time'));

%% States
figure('Name',sprintf('States'));
hStates = [];
for iState = 1:const.nStates
    if ~isempty(xr)
        xrCurrent = xr(iState,:);
    else
        xrCurrent = [];
    end

    hStates(end+1) = subplot(2,3,iState);
    hold on;
    plotState(simDataCell, 'x', iState, simNames, ...
        const.stateNames{iState}, const.statePlottingUnits{iState},...
        const.statePlottingSF(iState), xrCurrent);
    % legend();
end

% Alpha
hStates(end+1) = subplot(2,3,6);
hold on;
for iTraj = 1:numel(simDataCell)
    simData = simDataCell{iTraj};
    data = calcAlpha(simData.x);
    t = simData.times;
    plot(t,data*rad2deg(1),'LineWidth',1.5);%,'DisplayName',simNames{iTraj});
    hold on;
end
yline(rad2deg(const.constraint.amax),'r--','LineWidth',1.5);%,'DisplayName','State Constraint');
yline(rad2deg(-const.constraint.amax),'r--','LineWidth',1.5);%,'HandleVisibility','off');
xlabel('Time (s)');
ylabel(sprintf('%s (%s)', 'Alpha', 'deg'));
grid on;   
legend(simNames{:},'State Constraint');
ax = gca;
ax.LineWidth = 2;  % Thicker axes
ax.FontSize = 12;

linkaxes(hStates,'x');
sgtitle(sprintf('States vs Time'))

end


function plotState(simDataCell, dataName, stateIdx, simNames, stateName, stateUnits,SF, xr)
    for iTraj = 1:numel(simDataCell)
        simData = simDataCell{iTraj};
        data = simData.(dataName)(stateIdx,:);
        t = simData.times;
        plot(t,data*SF,'DisplayName',simNames{iTraj},'LineWidth',1.5);
    end

    if ~isempty(xr)
        plot(t, xr*SF,'r--','DisplayName','Reference Trajectory','LineWidth',1.5);
    end

    xlabel('Time (s)');
    ylabel(sprintf('%s (%s)', stateName, stateUnits));
    grid on;  
    legend();
    ax = gca;
    ax.LineWidth = 2;  % Thicker axes
    ax.FontSize = 12;
end