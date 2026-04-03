function [const] = ModelParams(varargin)
    FEET_TO_M = 0.3048;

    const = struct();
    
    const.nStates = 5;
    const.stateNames = {'V','gamma','q','theta','h'};
    const.stateUnits = {'m/s','rad','rad/s','rad','m'};

    const.inputNames = {'phi','deltaE','deltaC'};
    const.inputUnits = {'-','rad','rad'};

    const.g = 9.81; % m/s^2

    % TODO - update these with paper values
    vehicleLength = 100*FEET_TO_M; % 100 ft to m
    const.gravimetrics.m = 4377*vehicleLength; % kg (300 slugs/ft???)
    const.gravimetrics.Iyy = 5E5*1.35581795*vehicleLength; % kg.m^2 (5E5 slugs.ft^2/ft)

    const.thrust.zOffset = 2.548;

    const.aero.refArea = (17*FEET_TO_M^2)/FEET_TO_M * vehicleLength;
    const.aero.refLength = 5.1816;
    const.aero.CL_alpha = 4.6773; % rad^-1
    const.aero.CL_deltaE = 7.6224E-1; % rad^-1
    const.aero.CL_deltaC = ???; % Do we just make this negative of deltaE?
    


    %% Pull out specific parameter if required
    nArgs = length(varargin);
    if nArgs > 0
        for iArg = 1:nArgs
            const = const.(varargin{iArg});
        end
    end


end