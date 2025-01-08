function [Cd, Cl] = netHydroVar(cosTheta, Sn, imodel)
%####################################################
% This function is principally used for updating Cd &
% Cl for within the calculation of drag force induced 
% by both wave and current
%####################################################
sin2Theta =  1- cosTheta.^2;
switch imodel
    case 1 %
        Cd = 0.04 + (-0.04 + Sn - 1.24*Sn^2 + 13.7*Sn^3)*abs(cosTheta);
        Cl = (0.57*Sn -3.54*Sn^2 + 10.1*Sn^3) * sin2Theta;
    case  2 % Løland's screen model
        Cd = 0.04 + (-0.04 + 0.33*Sn + 6.54*Sn^2 -4.88*Sn^3)*abs(cosTheta);
        Cl = (-0.05*Sn +2.3*Sn^2 -1.76*Sn^3) * sin2Theta;
    case 3
    case 4
    case 5
    case 6
    end

end