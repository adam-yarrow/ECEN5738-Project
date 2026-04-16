function [t, y] = RK4(f, tspan, y0, h)
% RK4  Classic 4th-order Runge-Kutta integrator
%
% INPUTS:
%   f     - function handle: dydt = f(t, y)
%   tspan - [t_start, t_end]
%   y0    - initial condition (column vector)
%   h     - step size
%
% OUTPUTS:
%   t - time vector
%   y - solution matrix (each row is the state at time t(i))
%
% EXAMPLE (simple harmonic oscillator):
%   f = @(t, y) [y(2); -y(1)];
%   [t, y] = rk4(f, [0, 10], [1; 0], 0.01);
%   plot(t, y(:,1));

    t = (tspan(1):h:tspan(2))';
    n = length(t);
    y = zeros(n, length(y0));
    y(1, :) = y0(:)';          % store initial condition as row

    prevPrint = 0;
    for i = 1:n-1
       
        ti = t(i);
        yi = y(i, :)';         % current state as column vector

        if t(i) - prevPrint > 1
            display(t(i));
            prevPrint = t(i);
        end
        k1 = f(ti,       yi);
        k2 = f(ti + h/2, yi + h/2 * k1);
        k3 = f(ti + h/2, yi + h/2 * k2);
        k4 = f(ti + h,   yi + h   * k3);

        y(i+1, :) = (yi + (h/6) * (k1 + 2*k2 + 2*k3 + k4))';
    end
end