clear all; close all; clc;
Startup;

%% Defining the Flight Conditions - Typical Cruise Conditions

V_r_ft = 6815;               % [ft/s] Pg. 7 in Paper
h_r_ft = 85000;              % [ft] 

ft_TO_m = 0.3048;
V_r = V_r_ft * ft_TO_m;      % [m/s] Trim Velocity
gamma_r = 0;                 % [rad]
q_r = 0;                     % [rad/s]
theta_r = 0;                 % [rad]
h_r = h_r_ft * ft_TO_m;      % [m] Ref Altitude

x_r = [V_r; gamma_r; q_r; theta_r; h_r];
xDot_r = zeros(5, 1);        % Static trim condition

%% Defining the Matrices for CLF

F = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 1 0];
G = [1 0 0; 0 1 0; 0 0 1; 0 0 0];  
Q_ARE = diag([0.25, 4.44e7, 1.11e7, 0.10]); 
R_ARE = diag([81.6, 4.44e5, 81.6]); 
[P, ~, ~] = care(F, G, Q_ARE, R_ARE);

%% Wrap CLF for the Simulation
clf_wrapper = @(t, x) calcCLFControl(x, x_r, xDot_r, P);

%% Defining ICs

V_ic_ft = V_r_ft - 400;      % [ft/s] Initial velocity -> 400 ft/s less than trim
V_ic = V_ic_ft * ft_TO_m;    % [m/s]

xIC = [V_ic; 0; 0; 0; h_r]; 
tEnd = 2; 

%% Simulation and Plot

simData = Simulation(xIC, clf_wrapper, tEnd);

figure;
subplot(2,1,1);
plot(simData.times, simData.x(1,:), 'b', 'LineWidth', 1.5);
yline(V_r, '--r', 'LineWidth', 1.5);
title('Velocity Tracking (m/s)');
ylabel('Velocity [m/s]');
legend('Actual', 'Reference', 'Location', 'best');
grid on;

subplot(2,1,2);
plot(simData.times, rad2deg(simData.x(2,:)), 'b', 'LineWidth', 1.5);
title('Flight Path Angle (\gamma)');
ylabel('Angle [deg]');
xlabel('Time [s]');
grid on;