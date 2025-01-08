function results =  SIMA_readMyResults(path,Dmark,IndexBod)
results             = [];
results.time_SIMO   = [];
results.time_RIFLEX = [];
results.platMotions = [];
results.nodalForces = [];
addpath('simaReader') 

    %---------------------------------------------------------------------------------------
    %%READ SIMULATION OUTPUT
    [nchan, nts, dt, chanNames] = readSIMO_resultstext([path Dmark 'results.txt']);
    % Read the binary file
    AA = read_simoresults([path Dmark  'results.tda'],nts);
    sizeAA = size(AA);

    if (sizeAA(1)<nts || nts<1); disp('Unable to read SIMO results'); return; end;
    % Determine which channels to read for the platform motions, wave
    % elevation
    for ibod = 1:length(IndexBod)
        ihullBody = IndexBod(ibod);
        [chanMotions, chanWave] = getchannelNumbers(chanNames,ihullBody);
        if (chanMotions(1)<1 || chanWave<1); disp('Unable to read SIMO results'); return; end;
        results.platMotions = [results.platMotions, AA(:,chanMotions)];
        % results.wave       = [results.wave, AA(:,chanWave)];
    end
    results.time_SIMO = AA(:,2);
    
    % -- Read the RIFLEX force output file -----------------------------
    %     fname = [folder Dmark prefix '_elmfor.bin'];
    %     BB = read_rifbin(fname,10000,numForChan);
    %     sizeBB = size(BB);
    %     if(sizeBB(1)<1); disp('Unable to read RIFLEX force results'); return; end;



    % -- Read the wind turbine results ---------------------------------
    %     fname = [folder Dmark prefix '_witurb.bin'];
    %     CC = read_rifbin(fname,0,26);
    %     sizeCC = size(CC);
    %     Nt = sizeCC(1);  % get the number of time steps
    %     if Nt<2; disp('Unable to read RIFLEX wind turbine results'); return; end; 
    %     
    %     time_WT = CC(:,2);
    %     omega = CC(:,3)*pi/180; % convert from deg/s to rad/s
    %     genTq = CC(:,5); 
    %     genPwr = CC(:,6); %
    %     azimuth = CC(:,7); 
    %     HubWindX = CC(:,8);
    %     HubWindY = CC(:,9);
    %     HubWindZ = CC(:,10);
    %     AeroForceX = CC(:,11);
    %     AeroMomX = CC(:,14);
    %     Bl1Pitch = CC(:,17);
    %     Bl2Pitch = CC(:,18);
    %     Bl3Pitch = CC(:,19); 

end