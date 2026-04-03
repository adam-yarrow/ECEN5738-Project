function [const] = ModelParams(varargin)
    const = struct();

    const.nStates = 5;
    const.stateNames = {'V','gamma','q','theta','h'};
    const.stateUnits = {'m/s','rad','rad/s','rad','m'};

    const.inputNames = {'phi','deltaE','deltaC'};
    const.inputUnits = {'-','rad','rad'};

    const.g = 9.81; % m/s^2

    % TODO - update these with paper values
    const.gravimetrics.m = 1;
    const.gravimetrics.Iyy = 1;

    const.thrust.zOffset = 1;

    const.aero.refArea = 1;
    const.aero.refLength = 1;


    %% Pull out specific parameter if required
    nArgs = length(varargin);
    if nArgs > 0
        for iArg = 1:nArgs
            const = const.(varargin{iArg});
        end
    end


end