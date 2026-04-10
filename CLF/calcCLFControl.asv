function [u, exit] = calcCLFControl(x, x_r, xDot_r, P, const)


    exit = 0;

    % Get the Lie Derivatives
    [LfV, LgV] = calcCLFLieDerivs(x, x_r, xDot_r, P, const);
    z = x(1:4) - x_r(1:4);
    
    % Defining V and other params
    epsilon = 0.01; % From Eq. 31
    V = z' * P * z;
    unknown_term = 0; % Unknown Term in Eq 15
    % Replace Unknown Term later with : abs(grad_V * G * l_sq * W)
    
    % Solving by QP
    % QP minimizes (0.5*x'*H*x) + f'*x
    % For our problem, we minimize u'*u, So H = 2*I & f' = 0
    H = 2 * eye(3); 
    f = zeros(3, 1);
    
    % QP requires the constraint to be of the form A*x </= b
    A = LgV; 
    b = -LfV - epsilon * V - unknown_term;
    
    lb = [0; -deg2rad(30); -deg2rad(30)]; % Minimums [phi, delta_e, delta_c]
    ub = [1.2; deg2rad(30); deg2rad(30)]; % Maximums
    
    options = optimoptions('quadprog', 'Display', 'off');
    u = quadprog(H, f, A, b, [], [], lb, ub, [], options);
    
    % If QP is completely infeasible with bounds, fallback to zero effort
    if isempty(u)
        u = [0; 0; 0]; 
    end
end