%{
    This script allows for the evaluation of multiple control strategies.
%}
const = ModelParams();

%% Testing KKT CLF-CBF
tEnd = 55;

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
simData_CBFon = Simulation(xIC, clfCbfKKT, tEnd);

fCBFactive = false;
clfCbfKKT = @(t,x,const) CoupledCLF_CBF(t,x,const,@getRefTraj,P,fCBFactive);
simData_CBFoff = Simulation(xIC, clfCbfKKT, tEnd);

plotSimulationResults({simData_CBFon, simData_CBFoff}, {'CBF ON','CBF OFF'},@getRefTraj, P);




