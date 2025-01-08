function [t,x] = solverVerletInt(f,tSpan,x0)

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
upd = textprogressbar(length(tSpan));



it = 2;
for i = 2:length(t)
    % ---------------------------------------------------------------------
    dvdt1  = f(t(i-1), x(:,i-1));
    x(1:ndof,i) =  x(1:ndof,i-1) + x(ndof+1:2*ndof,i-1)*dt +...
                   0.5* dvdt1(ndof+1:2*ndof)*dt^2;
    xInp = [x(1:ndof,i-1); x(ndof+1:2*ndof,i)];
    dvdt2  = f(t(i-1), xInp);
    x(ndof+1:2*ndof,i) =  x(ndof+1:2*ndof,i-1) + ...
                          0.5*(dvdt1(ndof+1:2*ndof) + dvdt2(ndof+1:2*ndof))*dt;
    % ---------------------------------------------------------------------
    upd(i) 
    
    vel = x(length(x0)/2+1:length(x0),:);
    it = i;
end
x = x';
t = t';




toc
disp('>>> END SIMU   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
disp('------------------------------------------------')
end