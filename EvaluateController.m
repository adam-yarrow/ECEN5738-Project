%{
    This script allows for the evaluation of multiple control strategies.
%}
const = ModelParams();

%% Testing KKT CLF-CBF
tEnd = 32;

% IC
xIC = getRefTraj(0);
Vref = xIC(1);
% xIC(4) = deg2rad(5);
xIC(5) = xIC(5) + 300;
xIC(1) = xIC(1) - 121.92; % Slight perturbation on velocity (400ft/s less)

% Tuning
[Q_ARE, R_ARE] = buildQR_ARE(const); 
P = getLyapP(Q_ARE, R_ARE, Vref, const);

% Annonymous Control func
fCBFactive = true;
clfCbfKKT = @(t,x,const) CoupledCLF_CBF(t,x,const,@getRefTraj,P,fCBFactive);
profile on;
simData_KKT = Simulation(xIC, clfCbfKKT, tEnd);
profile viewer
plotSimulationResults(simData_KKT, 'KKT Controller - CBF ON',@getRefTraj, P);


% %% No Control - Testing Open Loop Response
% xIC_Regulation = [2077;
%                   0;
%                   0;
%                   0;
%                   25908];
% tEnd = 10;
% 
% simData_CBF = Simulation(xIC_Regulation, @CBFControl,tEnd);
% plotSimulationResults(simData_CBF,'CBF Controller');
% 
% simData_OL = Simulation(xIC_Regulation, @OpenLoopControl,tEnd);
% plotSimulationResults(simData_OL,'OL Controller');
% 
% % PID
% simData_PID = Simulation(xIC_Regulation, @PID,tEnd);
% plotSimulationResults(simData_PID,'PID on Pitch Rate Controller');






