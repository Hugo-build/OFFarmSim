function [Cd, Cl] = netHydro(theta, Sn, imodel)

switch imodel
    case 1
        Cd = 0.04 + (-0.04 + Sn - 1.24*Sn^2 + 13.7*Sn^3)*abs(cosd(theta));
        Cl = (0.57*Sn -3.54*Sn^2 + 10.1*Sn^3) * sind(2*theta);
    case  2 % Løland's screen model
        Cd = 0.04 + (-0.04 + 0.33*Sn + 6.54*Sn^2 -4.88*Sn^3)*cosd(theta);
        Cl = (-0.05*Sn +2.3*Sn^2 -1.76*Sn^3) * sind(2*theta);
    end

end

