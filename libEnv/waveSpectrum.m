function Shh = waveSpectrum(iType, parVec, omegaVec, plotFlag)

Shh = [];
g = 9.81;  % [m/s^2] gravity acceleration 
switch nargin
    % =====================================================================
    case 0 % case that no inputs from the user
        disp('>> 1 for JONSWAP, parVec: [Hs, 1/Tp, gamma], omegaVec, plotFlag) <<')
    % =====================================================================    
    otherwise
    switch iType
        % -----------------------------------------------------------------
        case 1 % JONSWAP parVec(Hs, Tp, gamma)
            Hs	  =  parVec(1);
            wp    =  2*pi/parVec(2);
            gamma =  parVec(3);
            W     =  omegaVec;
            alpha =  0.2*Hs^2*wp^4/g^2;
            if gamma<1 | gamma > 7 %DNV recommeded values when gamma is unknown.
		        if gamma ~= 0
			        % Display warning if gamma is outside validity range and not
			        % set to zero
			        disp(['Warning: gamma value in wave_spectrum function...' ...
                          ' outside validity range, using DNV formula'])
		        end
		        k=2*pi/(wp*sqrt(Hs));
                if k <= 3.6
                   gamma = 5;
                elseif k <= 5
	               gamma = exp(5.75-1.15*k);
                else % k > 5
	               gamma = 1;
                end
            end
            for k=1:1:length(W)
                if  W(k) < wp
                     sigma=0.07;
                else
                     sigma=0.09;
                end
                S1=alpha*g^2*(W(k)^-5)*exp(-(5/4)*(wp/W(k))^4);
                S2=gamma^(exp(-(W(k)-wp)^2/(2*(sigma*wp)^2)));
                % DNV conversion factor from <Environmenatal conditions and environmental
                % loads. April 2007, DNV-RP-C205>            
                % Conv_factor =  1-0.287*log(gamma); 
                Conv_factor = 1;
                Shh=[Shh;Conv_factor*S1*S2];
            end
            titleStr='JONSWAP Spectrum';
            legendStr = [' gamma =',num2str(gamma),...
                         ' Hs =',num2str(Hs),' [m],',...
                         ' Tp=',num2str(2*pi/wp),' [s]'];
        %------------------------------------------------------------------
        otherwise
            disp('No other spectrum for now')
    end

    if plotFlag == 1
	    plot(W, Shh,'b','linewidth',1)
	    title(titleStr)
        legend(legendStr)
	    xlabel('\omega [rad/s]')
	    ylabel('S(\omega) [m^2 s]')
    end
    % =====================================================================
end
end