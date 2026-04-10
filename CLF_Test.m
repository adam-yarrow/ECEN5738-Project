clear all; close all; clc;
Startup;

%% Defining the Flight Conditions - Typical Cruise Conditions

V_r_ft = 6815;               % [ft/s] Pg. 7 in Paper
h_r_ft = 85000;              % [ft] 

ft_TO_m = 0.3048;
V_r = V_r_ft * ft_TO_m;      % [m/s] Trim Velocity
gamma_r = 0;                 % [rad] Flight Path Angle
q_r = 0;                     % [rad/s] Pitch Rate
theta_r = deg2rad(0);        % [rad] Pitch Angle
h_r = h_r_ft * ft_TO_m;      % [m] Ref Altitude

x_r = [V_r; gamma_r; q_r; theta_r; h_r];
xDot_r = zeros(5, 1);        % Static trim condition

%% Defining the Matrices for CLF

F = [0 0 0 0 0; 0 0 0 0 0; 0 0 0 0 0; 0 0 1 0 0; 0 V_r 0 0 0];
G = [1 0 0; 0 1 0; 0 0 1; 0 0 0; 0 0 0];  
Q_ARE = diag([0.25*(3.28^2), 4.44e7, 1.11e7, 4.44e5]); 
Q_ARE = diag([0.25*(3.28^2), 4.44e7, 1.11e7, 4.44e5, 100])
R_ARE = diag([0.1, 81.6, 81.6]); 
R_ARE = diag([1, 81.6, 81.6])
[P, ~, ~] = care(F, G, Q_ARE, R_ARE);

%% Wrap CLF for the Simulation
clf_wrapper = @(t, x, const) calcCLFControl(x, x_r, xDot_r, P, const);

%% Defining ICs

V_ic_ft = V_r_ft - 400;      % [ft/s] Initial velocity -> 400 ft/s less than trim
V_ic = V_ic_ft * ft_TO_m;    % [m/s]

xIC = [V_ic; 0; 0; 0; h_r]; 
tEnd = 100; 

%% Simulation

simData = Simulation(xIC, clf_wrapper, tEnd);

%% Plotting

figure;

% --- 1. Velocity ---
subplot(3,2,1)
plot(simData.times, simData.x(1,:), 'b', 'LineWidth', 1.5); hold on;
yline(V_r, '--r', 'LineWidth', 1.5);
title('Velocity Tracking')
ylabel('Velocity [m/s]')
legend('Actual','Reference','Location','best')
grid on

% --- 2. Flight Path Angle ---
subplot(3,2,2)
plot(simData.times, rad2deg(simData.x(2,:)), 'b', 'LineWidth', 1.5);
title('Flight Path Angle (\gamma)')
ylabel('[deg]')
grid on

% --- 3. Pitch Rate ---
subplot(3,2,3)
plot(simData.times, rad2deg(simData.x(3,:)), 'b', 'LineWidth', 1.5);
title('Pitch Rate (q)')
ylabel('[deg/s]')
grid on

% --- 4. Pitch Angle ---
subplot(3,2,4)
plot(simData.times, rad2deg(simData.x(4,:)), 'b', 'LineWidth', 1.5);
title('Pitch Angle (\theta)')
ylabel('[deg]')
grid on

% --- 5. Height ---
subplot(3,2,5)
plot(simData.times, simData.x(5,:), 'b', 'LineWidth', 1.5); hold on;
yline(h_r, '--r', 'LineWidth', 1.5);
title('Height (h)')
ylabel('[m]')
xlabel('Time [s]')
legend('Actual','Reference','Location','best')
grid on

% --- 6. Angle of Attack ---
subplot(3,2,6)
plot(simData.times, rad2deg(simData.x(4,:) - simData.x(2,:)), 'b', 'LineWidth', 1.5);
title('Angle of Attack (deg)')
ylabel('[deg/s]')
grid on

figure;

subplot(2,2,1)
plot(simData.times, simData.u(1,:), 'b', 'LineWidth', 1.5); hold on;
title('Fuel Equivalence Ratio (\phi)')
ylabel('\phi')
grid on

subplot(2,2,2)
plot(simData.times, rad2deg(simData.u(2,:)), 'b', 'LineWidth', 1.5);
title('Elevator Angle (\delta_e)')
ylabel('[deg]')
grid on

subplot(2,2,3)
plot(simData.times, rad2deg(simData.u(3,:)), 'b', 'LineWidth', 1.5);
title('Canard Angle (\delta_c)')
ylabel('[deg]')
grid on

% plotSimulationResults(simData,'CLF Test Results')
% 
% figure(1)
% subplot(2,3,1)
% yline(V_r, '--r', 'LineWidth', 1.5);
