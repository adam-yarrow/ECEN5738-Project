%% Finding the actual Normalized Relative Weights from Papers Q and R matrices
% inverting Bryson's rule making some assumptions around state maxes
Q_ARE = [0.25*(3.28^2), 4.44e7, 1.11e7, 4.44e5]; 
R_ARE = [0.1, 81.6, 81.6]; 

Vmax = 2200; % m/s (based on rough trim condition
thetaMax = pi/2;
gammaMax = pi/2;
qMax = deg2rad(100); %rad/s (estimate)

stateMaxes = [Vmax, gammaMax, qMax, thetaMax];

deltaEmax = deg2rad(30);
deltaCmax = deg2rad(30);
phiMax = 1.2;

controlMaxes = [phiMax, deltaEmax, deltaCmax];


%% Now find weightings
alpha_ii = (Q_ARE.*stateMaxes.^2).^0.5;
Qgain = sum(alpha_ii);
alpha_ii_normalized = alpha_ii ./ Qgain; % relative weights of each state

beta_ii = (R_ARE.*controlMaxes.^2).^0.5;
Rgain = sum(beta_ii);
beta_ii_normalized = beta_ii ./Rgain;


K_QR = Rgain/Qgain;

