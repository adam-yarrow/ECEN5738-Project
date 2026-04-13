function [xr, xrDot] = getRefTraj(t)
    %{
        Currently static reference trajectory
        TODO - make a dynamic version like the paper
    %}

    V_r_ft = 6815;               % [ft/s] Pg. 7 in Paper
    h_r_ft = 85000;              % [ft] 
    
    ft_TO_m = 0.3048;
    V_r = V_r_ft * ft_TO_m;      % [m/s] Trim Velocity
    gamma_r = 0;                 % [rad] Flight Path Angle
    q_r = 0;                     % [rad/s] Pitch Rate
    theta_r = deg2rad(0);        % [rad] Pitch Angle
    h_r = h_r_ft * ft_TO_m;      % [m] Ref Altitude
    
    xr = [V_r; gamma_r; q_r; theta_r; h_r];
    xrDot = zeros(5, 1);        % Static trim condition    
end