function plotThrust()
    const = ModelParams();

    alpha = deg2rad(-5:0.1:5);
    phi = 0:0.1:1.0;

    figure();
    hold on;
    for iPhi = 1:numel(phi)
        T = [];
        for iAlpha = 1:numel(alpha)
            T(end+1) = getThrust(alpha(iAlpha),phi(iPhi),const)/const.gravimetrics.m/const.g;
        end
        plot(rad2deg(alpha),T,'DisplayName',sprintf('phi = %f',phi(iPhi)));

    end

    xlabel('Angle of Attack (deg)');
    ylabel('THrust accel (g)');
    title('Thrust vs Angle of Attack');
    legend();
end