function F = FQSmoor(x,sys,floatBody,lineType,iconfig)

F = zeros(length(x)/2,1);
    % ================================================================================================================================================
    % update position of fairleads
    for ibod = 1:sys.nbod    
        sys.fairleadPos(1:2,floatBody(ibod).fairleadIndex) = x(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1) +...
                                                             sys.fairleadPos_init(1:2,floatBody(ibod).fairleadIndex);
    end
    % ================================================================================================================================================
    % Anchor line force calculation
    % disp('-----------------------------')
    for iline = 1:size(sys.anchorLinePair,1)
        xF2Anch_Vec_temp(:,iline) = sys.anchorPos(1:2, sys.anchorLinePair(iline,1)) -...
                                    sys.fairleadPos(1:2, sys.anchorLinePair(iline,2));
        xF2Anch_VecNorm_temp = norm(xF2Anch_Vec_temp(:,iline));

        % disp(xF2Anch_VecNorm_temp)                                       % For Debug?
        % disp(getTension(lineType(sys.anchorLineType(iline)),xF2Anch_VecNorm_temp)) %?

        [sys.Aline_FH(1,iline), sys.Aline_FV(1,iline)] = getTension(lineType(sys.anchorLineType(iline)), xF2Anch_VecNorm_temp);
        sys.Aline_proj2xy(:,iline) = xF2Anch_Vec_temp(:,iline)/xF2Anch_VecNorm_temp;
    end

    % =================================================================================================================================================
    % Sharedline force calculation
    if size(sys.sharedLinePair,1) == 0
        % --------------------------------------------------------
        % Assemble projected force in global X and Y to F vector
        for ibod = 1:sys.nbod
            F(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1,:) = F(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1,:)+...
                  (sys.Aline_FH(:,floatBody(ibod).AlineSlave)*...
                   sys.Aline_proj2xy(:,floatBody(ibod).AlineSlave)')'; 
        end
    else
        % --------------------------------------------------------
        for iline = 1:size(sys.sharedLinePair,1)
            xF2F_Vec_temp(:,iline) = sys.fairleadPos(1:2, sys.sharedLinePair(iline,2)) -...
                                     sys.fairleadPos(1:2, sys.sharedLinePair(iline,1));
            
            xF2F_VecNorm_temp = norm(xF2F_Vec_temp(:,iline));

            %disp(xF2F_VecNorm_temp) % For Debug

            [sys.Sline_FH(1:2,iline), sys.Sline_FV(1:2,iline)] = getTension2ends(lineType(sys.sharedLineType(iline)), xF2F_VecNorm_temp);
            sys.Sline_proj2xy(:,2*iline-1) = xF2F_Vec_temp(:,iline)/xF2F_VecNorm_temp;
            sys.Sline_proj2xy(:,2*iline)   = - sys.Sline_proj2xy(:,2*iline-1);
        end
        % --------------------------------------------------------
        % Assemble projected force in global X and Y to F vector
        for ibod = 1:sys.nbod
            F(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1,:) = F(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1,:)+...
                  (sys.Aline_FH(:,floatBody(ibod).AlineSlave)*...
                   sys.Aline_proj2xy(:,floatBody(ibod).AlineSlave)')'+...
                  (sys.Sline_FH(1,floatBody(ibod).SlineSlave(1,:))*...
                   sys.Sline_proj2xy(:,2*floatBody(ibod).SlineSlave(1,:)-floatBody(ibod).SlineSlave(2,:))')'; 

            %disp(sys.Sline_FH(1,floatBody(ibod).SlineSlave(1,:)))
            %disp(sys.Sline_proj2xy(:,2*floatBody(ibod).SlineSlave(1,:)-floatBody(ibod).SlineSlave(2,:)))
        end
        % --------------------------------------------------------        
    end
    %disp(F')

 % if iRes == 1
 %    global results
 %    results.mooringTension 
 % else
 % end

end