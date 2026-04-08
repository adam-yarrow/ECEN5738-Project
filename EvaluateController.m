%{
    This script allows for the evaluation of multiple control strategies.
%}

%% No Control - Testing Open Loop Response
xIC_Regulation = [2077;
                  0;
                  0;
                  0;
                  25908];
tEnd = 60;

simData_OL = Simulation(xIC_Regulation, @OpenLoopControl,tEnd);
plotSimulationResults(simData_OL,'OL Controller');

simData_CBF = Simulation(xIC_Regulation, @CBFControl,tEnd);
plotSimulationResults(simData_CBF,'CBF Controller');
