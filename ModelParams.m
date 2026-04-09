function [const] = ModelParams(varargin)
    FEET_TO_M = 0.3048;
    LB_TO_KG = 0.453;

    const = struct();

    const.dT = 1E-2; % TODO - decide on this???
    const.continuous = true;
    
    const.nStates = 5;
    const.stateNames = {'V','gamma','q','theta','h'};
    const.stateUnits = {'m/s','rad','rad/s','rad','m'};
    const.statePlottingUnits = {'m/s','deg','deg/s','deg','km'};
    const.statePlottingSF = [1, rad2deg(1), rad2deg(1), rad2deg(1), 1E-3];

    const.nInputs = 3;
    const.inputNames = {'phi','deltaE','deltaC'};
    const.inputUnits = {'-','rad','rad'};
    const.inputPlottingUnits = {'-','deg','deg'};
    const.inputPlottingSF = [1, rad2deg(1), rad2deg(1)];

    const.g = 9.81; % m/s^2

    %{
        NOTE: using "Control Orientated Modelling of an Air-Breathing
        Hypersonic Vehicle" by Parker, Bolender and Doman as the master
        source of truth for simulation parameters. 

        Assuming when any units are normalized by /ft it means they are
        scaled by the vehicle length.

        Assuming that the canard is identical to the elevator in lift/drag.

        Lordy what I'd give for metric units that are consistent between
        papers.
    %}

    vehicleLength = 100*FEET_TO_M; % 100 ft to m
    const.gravimetrics.m = 4377*vehicleLength; % kg (300 lb/ft - assuming normalized by length?)
    const.gravimetrics.Iyy = 5E5*1.35581795*vehicleLength; % kg.m^2 (5E5 slugs.ft^2/ft)

    % Thrust Params
    const.thrust.zOffset = 2.548; % m
    beta(1) = -3.7693e5;  % lb·ft^-1·rad^-3
    beta(2) = -3.7225e4;  % lb·ft^-1·rad^-3
    beta(3) =  2.6814e4;  % lb·ft^-1·rad^-2
    beta(4) = -1.7277e4;  % lb·ft^-1·rad^-2
    beta(5) =  3.5542e4;  % lb·ft^-1·rad^-1
    beta(6) = -2.4216e3;  % lb·ft^-1·rad^-1
    beta(7) =  6.3785e3;  % lb·ft^-1
    beta(8) = -1.0090e2;  % lb·ft^-1
    % TODO - does this need to be converted to N not kg?
    const.thrust.beta = beta*(LB_TO_KG/FEET_TO_M) * vehicleLength; 
    const.thrust.fDisableEngine = true; 

    % Aero Coeffs
    const.aero.refArea = (17*FEET_TO_M^2)/FEET_TO_M * vehicleLength; % 17ft^2/ft normalized to vehicle length
    const.aero.refLength = 17*FEET_TO_M; % m 

    % NOTE: assuming the canard is identical to the elevator in terms of
    % size
    kec = -1.5; % Scaling factor for moments in deltaE vs deltaC.
    % NOTE: I bastardised the paper "Control Orientated Modelling of
    % Air-Breathing Hypersonic Vehicles" by Parker et al.
    const.aero.CL_alpha = 4.6773; % rad^-1
    const.aero.CL_deltaE = 7.6224E-1; % rad^-1
    const.aero.CL_deltaC = const.aero.CL_deltaE; % Assuming canard == elevator
    const.aero.CL_0 = -1.8714E-2;

    const.aero.CD_alphaSq = 5.8224; % rad^-2
    const.aero.CD_alpha = -4.5315E-2; % rad^-1
    const.aero.CD_deltaESq = 8.1993E-1; % rad^-2
    const.aero.CD_deltaE = 2.7699E-4; % rad^-1
    const.aero.CD_deltaCSq = const.aero.CD_deltaESq; % rad^-2
    const.aero.CD_deltaC = const.aero.CD_deltaE; % rad^-1
    const.aero.CD_0 = 1.0131E-2; 

    const.aero.CM_alphaSq = 6.2926; % rad^-2
    const.aero.CM_alpha = 2.1335; % rad^-1
    const.aero.CM_0 = 1.8979E-1;
    const.aero.CM_deltaE = -1.2897; % rad^-1
    const.aero.CM_deltaC = kec * const.aero.CM_deltaE;

    const.constraint.amax = deg2rad(4.5);
    const.constraint.phiBounds = [0, 1.2];
    const.constraint.deltaEBounds = [-deg2rad(30), deg2rad(30)];
    const.constraint.deltaCBounds = [-deg2rad(30), deg2rad(30)];

    const.aero.fMakeStaticallyStable = true; 
    
    %% Pull out specific parameter if required
    nArgs = length(varargin);
    if nArgs > 0
        for iArg = 1:nArgs
            const = const.(varargin{iArg});
        end
    end


end