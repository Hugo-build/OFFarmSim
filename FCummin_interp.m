
function F = FCummin_interp(t,retarData,dtCon,simTime)

% ----------------------------------
% 2Do: improve efficiency
% 2Do: add floatBody interplolation
% 2Do: imrove on Nddt
% -----------------------------------


Nddt = retarData.Nddt;

global it 
global vel
persistent velCal
    
    if simTime(it)<=round(retarData.tau(end))
        tCal   = simTime(1):dtCon:simTime(it);
        velCal = zeros(size(vel,1), length(tCal));
        for idof = 1:size(vel,1)
            velCal(idof,:) = interp1(simTime(it:-1:1),vel(idof,it:-1:1),simTime(it)-tCal, 'linear');
        end
    else
        
        tCal   = retarData.tau; 
        if size(velCal,2) < length(tCal)

            % make sure the 2nd dimesion of velVal is the same as K.
            velCal = [velCal, zeros(size(vel,1),length(tCal)-size(velCal,2))];

        end
        for idof = 1:size(vel,1)
            
            % move old velocities backward
            velCal(idof, 1+Nddt:end) = velCal(idof, 1:end-Nddt);

            % Only interp between nt-1 and nt steps.
            vel_inte_01 = linspace(vel(it),vel(it-1),Nddt+1);
            velCal(idof, 1:Nddt)     = vel_inte_01(1:Nddt); 
            
        end
    end


    % ! This is only for one body
    
    if size(vel,1) == 2
        for irow = 1:2         
            F(irow,:) = sum(retarData.K( (irow-1)*6+1:(irow-1)*6+2, 1:length(tCal) ).* velCal * dtCon,"all");
        end
    elseif size(vel,1) == 6
       
        for irow = 1:6   
            F(irow,:) = sum(retarData.K( (irow-1)*6+1:(irow-1)*6+6, 1:length(tCal) ).* velCal * dtCon,"all");
        end
        
    end

end