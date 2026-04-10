function [u, exit] = PID(t, x, const)
    % Try to control q to zero
    % Full throttle baby!
    Kp = 10;
    Ki = 100; % just a guess lol

    exit = 0;

    qRef = 0;
    thetaRef = 0;

    mixing = [-0.5, 0.5];
    virtualElevator =  (-Kp*(x(3) - qRef) - Ki*(x(4) - thetaRef));
    deltaE_cmd = mixing(1) * virtualElevator;
    deltaC_cmd = mixing(2) * virtualElevator;

    deltaE_cmd = saturateAct(deltaE_cmd); 
    deltaC_cmd = saturateAct(deltaC_cmd);

    u = [1.0; deltaE_cmd; deltaC_cmd];
end

function cmdLim = saturateAct(cmd)
     cmdLim = min([abs(cmd),deg2rad(30)])*sign(cmd);
end