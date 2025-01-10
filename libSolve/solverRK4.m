function [t,x] = solverRK4(f,tSpan, x0)
disp('------------------------------------------------')
disp('>>> BEGIN SIMU >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
tic

ndof = length(x0)/2;
disp('------------------------------------------------')
disp('Inital position for Hydrodynamics :: ')
disp(x0(1:ndof)')

x = zeros(length(x0),length(tSpan));
x(:,1) = x0;

t = tSpan;
dt = tSpan(2)-tSpan(1);
%upd = textprogressbar(length(tSpan));

%global vel
%global it
%it = 2;
for i = 2:length(t)
   % ---------------------------------------------------------------------
    k1 = dt * f(t(i-1), x(:,i-1));
    k2 = dt * f(t(i-1) + 0.5*dt, x(:,i-1) + 0.5*k1);
    k3 = dt * f(t(i-1) + 0.5*dt, x(:,i-1) + 0.5*k2);
    k4 = dt * f(t(i-1) + dt, x(:,i-1) + k3);
    x(:,i) = x(:,i-1) + (1/6) * (k1 + 2*k2 + 2*k3 + k4);
   % ---------------------------------------------------------------------
   %upd(i)  
  
   %vel = x(length(x0)/2+1:length(x0),:);
   %it = i;
end
x = x';
t = t';



toc
disp('>>> END SIMU   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
disp('------------------------------------------------')
end

