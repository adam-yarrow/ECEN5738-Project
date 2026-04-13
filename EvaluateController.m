%{
    This script allows for the evaluation of multiple control strategies.
%}

%% Testing KKT CLF-CBF
tEnd = 50;

xIC = getRefTraj(0);
xIC(1) = xIC(1) - 121.92; % Slight perturbation on velocity

% TODO - move Q and R to constants once decided on approach
Q_ARE = diag([0.25*(3.28^2), 4.44e7, 1.11e7, 4.44e5]); 
R_ARE = diag([0.1, 81.6, 81.6]); 
P = getLyapP(Q_ARE, R_ARE);

fCBFactive = true;

% Annonymous Control func
clfCbfKKT = @(t,x,const) CoupledCLF_CBF(t,x,const,@getRefTraj,P,fCBFactive);

simData_KKT = Simulation(xIC, clfCbfKKT, tEnd);
plotSimulationResults(simData_KKT, 'KKT Controller');


%% No Control - Testing Open Loop Response
xIC_Regulation = [2077;
                  0;
                  0;
                  0;
                  25908];
tEnd = 60;

simData_CBF = Simulation(xIC_Regulation, @CBFControl,tEnd);
plotSimulationResults(simData_CBF,'CBF Controller');

simData_OL = Simulation(xIC_Regulation, @OpenLoopControl,tEnd);
plotSimulationResults(simData_OL,'OL Controller');

% PID
simData_PID = Simulation(xIC_Regulation, @PID,tEnd);
plotSimulationResults(simData_PID,'PID on Pitch Rate Controller');






