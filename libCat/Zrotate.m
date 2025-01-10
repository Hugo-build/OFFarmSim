function T = Zrotate(alpha, beta)
% -- Explanation goes -----
% alpha means cos(theta)
% beta means sin(theta)
% -------------------------
    T = [alpha, -beta, 0;...
          beta, alpha, 0;...
             0,     0, 1];
end