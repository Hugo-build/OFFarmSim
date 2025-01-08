function f = Fconv_OT(t,x,retardata, nbod, threshold)
    global vHistory
    global tHistory
    global fmem
    
    v = x(length(x)/2+1:length(x));
    if t==0
        vHistory = zeros(length(x)/2,length(retardata.t));
        tHistory = -flip(retardata.t(:)');
        fmem     = zeros(length(x)/2,1);
        f        = fmem;  
    else
        if t-tHistory(end)<threshold
            f = fmem(:,end); 
            % disp(tHistory)%--> For Debug
            % disp(vHistory)%--> For Debug
            
        else    
            vHistory = [vHistory, v];
            tHistory = [tHistory, t];
            % --------------------------------------------------
            % disp(tHistory)%--> For Debug
            % disp(vHistory)%--> For Debug
            % fprintf('Current time: %.3f\n', t) %--> For Debug
          % --------------------------------------------------
            % Find the range of velocity that still can impulse the system
            index    = tHistory>tHistory(end)-retardata.t(end)&tHistory<=tHistory(end);
            tauRange = tHistory(index);
            vRange   = vHistory(:,index);        
            %disp(numel(tHistory))

            % ------------------------------------------------------------------
            % Interpolation and Direct Calculation
            if tauRange(1)>0 % To calculate after all needed time slice > t=0s.
                for ibod = 1:nbod
                    % Get unique values and their indices
                    [uniqueTau, idxTau, ~] = unique(tauRange);
                    %disp(uniqueTau) %--> For Debug
                    idx_lastBod = 6*(ibod-1);
                    % Use these indices to get the corresponding vRange values
                    uniqueV1 = vRange(idx_lastBod+1, idxTau);
                    uniqueV2 = vRange(idx_lastBod+2, idxTau);
                    uniqueV3 = vRange(idx_lastBod+3, idxTau);
                    uniqueV4 = vRange(idx_lastBod+4, idxTau);
                    uniqueV5 = vRange(idx_lastBod+5, idxTau);
                    uniqueV6 = vRange(idx_lastBod+6, idxTau);
                    % disp(uniqueV1) %--> For Debug
    
                    % Now uniqueTau and uniqueV have the same length
                    % Interp the velocities with ideal resolution, predefined
                    % in retardata.t, in a backforward way
                    v1Interp = interp1(uniqueTau, uniqueV1, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");
                    v2Interp = interp1(uniqueTau, uniqueV2, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");
                    v3Interp = interp1(uniqueTau, uniqueV3, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");
                    v4Interp = interp1(uniqueTau, uniqueV4, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");
                    v5Interp = interp1(uniqueTau, uniqueV5, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");
                    v6Interp = interp1(uniqueTau, uniqueV6, ...
                        linspace( uniqueTau(end),uniqueTau(1), length(retardata.t)), "linear", "extrap");

                    
                    f1 = (retardata.k11* v1Interp' + retardata.k15* v5Interp' )* retardata.dt;
                    f2 = (retardata.k22* v2Interp' + retardata.k24* v4Interp') * retardata.dt;
                    f3 =  retardata.k33 * v3Interp' * retardata.dt;
                    f4 = (retardata.k44* v4Interp' + retardata.k24* v2Interp')  * retardata.dt;
                    f5 = (retardata.k55* v5Interp'  + retardata.k15* v1Interp' )* retardata.dt;
                    f6 =  retardata.k66 * v6Interp' * retardata.dt;
                       
                    f(idx_lastBod+1: idx_lastBod+6, 1) = [f1; f2; f3; f4; f5; f6];
                end
            else
                f = fmem(:,end); %fmem(:,1); %--> for further filter the load
            end
            % ------------------------------------------------------------------
        end
        fmem = [fmem, f];
    end
end