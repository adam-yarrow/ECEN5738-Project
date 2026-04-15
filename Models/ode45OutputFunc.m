function status = ode45OutputFunc(t, y, flag)
    switch flag
        case 'init'
            fprintf('Starting integration...\n');
        case ''
            fprintf('t = %.4f\n', t(end));
        case 'done'
            fprintf('Integration complete.\n');
    end
    status = 0;  % return 1 to halt integration early

    % Early Termination - if exceed +/- 90 degree bounds in theta or gamma
    if ~isempty(y) && (abs(y(2)) > pi/2 || abs(y(4)) > pi/2)
        status = 1;
        warning('Terminated ODE45 early due to exceeding theta or gamma limits');
    end
end