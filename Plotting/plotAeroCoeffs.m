function plotAeroCoeffs(const, alphaRange, deflectionAngles)
% PLOTAEROCOEFFS  Plot CL, CD, CM vs alpha for varying fin deflections
%
% INPUTS:
%   const            - Constants struct with const.aero fields
%   alphaRange       - [optional] 2-element vector [alpha_min, alpha_max] in rad
%                      Default: [-20, 20] deg converted to rad
%   deflectionAngles - [optional] vector of fin deflection angles to plot (rad)
%                      Default: [-15, -10, -5, 0, 5, 10, 15] deg in rad

%% --- Defaults ---
if nargin < 2 || isempty(alphaRange)
    alphaRange = deg2rad([-10, 10]);
end
if nargin < 3 || isempty(deflectionAngles)
    deflectionAngles = deg2rad(-20:5:20);
end

%% --- Setup ---
alpha      = linspace(alphaRange(1), alphaRange(2), 300);
alpha_deg  = rad2deg(alpha);
defls_deg  = rad2deg(deflectionAngles);
nDefls     = numel(deflectionAngles);
zeroIdx    = find(deflectionAngles == 0, 1);  % index of zero deflection (if present)

% Colormap: cool-to-warm, reserve black for zero deflection
cmap       = cool(nDefls);

% Line style helper: zero deflection gets black + thicker
function s = lineStyle(i)
    if ~isempty(zeroIdx) && i == zeroIdx
        s = {'Color', [0 0 0], 'LineWidth', 2.5, 'LineStyle', '-'};
    else
        s = {'Color', cmap(i,:), 'LineWidth', 1.4, 'LineStyle', '-'};
    end
end

coeffNames = {'C_L', 'C_D', 'C_M'};
figTitles  = {'Lift Coefficient', 'Drag Coefficient', 'Pitching Moment Coefficient'};
ylabels    = {'C_L', 'C_D', 'C_M'};

%% --- One figure per coefficient ---
for coeff = 1:3

    fig = figure('Name', figTitles{coeff}, 'NumberTitle', 'off', ...
                 'Position', [100 + (coeff-1)*60, 100, 960, 420]);

    % --- Subplot 1: deltaE sweep (deltaC = 0) ---
    ax1 = subplot(1, 2, 1);
    hold(ax1, 'on'); grid(ax1, 'on'); box(ax1, 'on');

    for i = 1:nDefls
        deltaE = deflectionAngles(i);
        [CL, CD, CM] = getAeroCoeffs(alpha, deltaE, 0, const);
        vals = selectCoeff(CL, CD, CM, coeff);

        % Always draw zero-deflection baseline last so it sits on top
        if ~isempty(zeroIdx) && i == zeroIdx, continue; end
        lineStyleI = lineStyle(i);
        plot(ax1, alpha_deg, vals, lineStyleI{:}, ...
             'DisplayName', sprintf('\\delta_E = %.0f°', defls_deg(i)));
    end
    % Draw zero-deflection line on top
    if ~isempty(zeroIdx)
        [CL0,CD0,CM0] = getAeroCoeffs(alpha, 0, 0, const);
        v0 = selectCoeff(CL0, CD0, CM0, coeff);
        lineStyleI = lineStyle(zeroIdx);
        plot(ax1, alpha_deg, v0, lineStyleI{:}, ...
             'DisplayName', '\delta_E = 0° (baseline)');
    end

    xlabel(ax1, '\alpha (deg)'); ylabel(ax1, ylabels{coeff});
    title(ax1, [figTitles{coeff} ' — \delta_E sweep (\delta_C = 0)']);
    legend(ax1, 'Location', 'best', 'FontSize', 7);

    % --- Subplot 2: deltaC sweep (deltaE = 0) ---
    ax2 = subplot(1, 2, 2);
    hold(ax2, 'on'); grid(ax2, 'on'); box(ax2, 'on');

    for i = 1:nDefls
        deltaC = deflectionAngles(i);
        [CL, CD, CM] = getAeroCoeffs(alpha, 0, deltaC, const);
        vals = selectCoeff(CL, CD, CM, coeff);

        if ~isempty(zeroIdx) && i == zeroIdx, continue; end
        lineStyleI = lineStyle(i);
        plot(ax2, alpha_deg, vals, lineStyleI{:}, ...
             'DisplayName', sprintf('\\delta_C = %.0f°', defls_deg(i)));
    end
    % Draw zero-deflection baseline on top
    if ~isempty(zeroIdx)
        [CL0,CD0,CM0] = getAeroCoeffs(alpha, 0, 0, const);
        v0 = selectCoeff(CL0, CD0, CM0, coeff);
        lineStyleI = lineStyle(zeroIdx);
        plot(ax2, alpha_deg, v0, lineStyleI{:}, ...
             'DisplayName', '\delta_C = 0° (baseline)');
    end

    xlabel(ax2, '\alpha (deg)'); ylabel(ax2, ylabels{coeff});
    title(ax2, [figTitles{coeff} ' — \delta_C sweep (\delta_E = 0)']);
    legend(ax2, 'Location', 'best', 'FontSize', 7);

    sgtitle(fig, figTitles{coeff}, 'FontSize', 13, 'FontWeight', 'bold');
end

end % plotAeroCoeffs

%% --- Helper: pick the right coefficient from the tuple ---
function vals = selectCoeff(CL, CD, CM, idx)
    switch idx
        case 1, vals = CL;
        case 2, vals = CD;
        case 3, vals = CM;
    end
end