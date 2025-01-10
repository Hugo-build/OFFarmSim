function DDoFName = getDDoFName(iDDoF, numDoF)

    dofNames = {'surge', 'sway', 'heave', 'roll', 'pitch', 'yaw'};
    
    % Ensure we don't exceed the available DoF names
    numDoF = min(numDoF, length(dofNames));
    
    row = ceil(iDDoF / numDoF);
    col = mod(iDDoF - 1, numDoF) + 1;
    
    if row > length(dofNames) || col > length(dofNames)
        dofCombo = sprintf('DoF %d', iDDoF);
    else
        dofCombo = sprintf('%s-%s', dofNames{row}, dofNames{col});
    end
    DDoFName = dofCombo;
    
end