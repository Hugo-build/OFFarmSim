function T = rotEular3D(Ang,type)

% --- If check SIMA documentation ---
% https://sima.sintef.no/doc/4.4.0/simo/theory/equations_of_motion.html
%   [Ang] is a vector = [\phi, \theta, \psi] or 
%                       [\phi, \theta, \psi]^T
% 1 \phi
% 2 \theta
% 3 \psi

switch type
    case "rad"
        Ang = Ang;
    case "deg"
        Ang = Ang/180*pi;
end

T = [cos(Ang(3))*cos(Ang(2)), -sin(Ang(3))*cos(Ang(1))+cos(Ang(3))*sin(Ang(2))*sin(Ang(1)),  sin(Ang(3))*sin(Ang(1))+cos(Ang(3))*sin(Ang(2))*cos(Ang(1));...
     sin(Ang(3))*cos(Ang(2)),  cos(Ang(3))*cos(Ang(1))+sin(Ang(3))*sin(Ang(2))*sin(Ang(1)), -cos(Ang(3))*sin(Ang(1))+sin(Ang(3))*sin(Ang(2))*cos(Ang(1));...
     -sin(Ang(2))           ,  cos(Ang(2))*sin(Ang(1))                                    ,  cos(Ang(2))*cos(Ang(1))                      ];
end