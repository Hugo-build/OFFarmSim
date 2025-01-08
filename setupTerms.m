function varargout = setupTerms()

    motionName = ["surge","sway","heave","roll","pitch","yaw"];
    motionDoF = 1:6;
    for ix = 1:6
        for iy = 1:6
            coupleName(ix,iy) = string([char(motionName(ix)) '-' char(motionName(iy))]);
        end
    end
    
    for i = 1:6
        for j = 1:6
            % Populate each cell with a random 1x2 array
            coupleDoF(i,j) = 6*(i-1)+j;
        end
    end
    
    dict4ddof = dictionary(coupleName, coupleDoF);
    dict4dof  = dictionary(motionName, motionDoF);

   % Convert motionDoF to string array
    dofFoot = string(motionDoF);

    % Create ddofFoot
    ddofFoot = strings(6, 6);
    for i = 1:6
        for j = 1:6
            ddofFoot(i,j) = sprintf('%d%d', motionDoF(i), motionDoF(j));
        end
    end

    % Define all possible outputs in a cell array
    allOutputs = {motionName, motionDoF, coupleName, coupleDoF,dofFoot, ddofFoot, dict4dof, dict4ddof};
    
    % Assign outputs based on number of requested outputs
    varargout = allOutputs(1:nargout);
end
