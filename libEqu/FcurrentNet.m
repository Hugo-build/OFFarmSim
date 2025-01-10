function F = FcurrentNet(t,x,floatBody,current)
    nodeList = floatBody.type2node_L("net"):floatBody.type2node_R("net");
   % disp(nodeList); % For debug
   % --- Current drag --------------------
    rho = 1025;
    nbod = length(floatBody);
    ndof = length(x)/2;
    F = zeros(ndof,1);
    
    for ibod = 1:nbod
        %if ndof == 2*nbod
        floatBody(ibod).attachNodePos(1:3,nodeList) = floatBody(ibod).attachNodePos_init(1:3,nodeList) +...
                                               x( (6*(ibod-1)+1):(6*(ibod-1)+3) );
       
       
        % elseif ndof == 6*nbod
        % floatBody(ibod).attachNodePos(1:3,:) = floatBody(ibod).attachNodePos(1:3,:) + cross(x((6*(ibod-1)+4):(6*(ibod-1)+6)), floatBody(ibod).attachNodePos_init(1:3,:));
        % floatBody(ibod).attachNodePos(1:3,:) = rotEular3D(x( (6*(ibod-1)+4):(6*(ibod-1)+6)) )*floatBody(ibod).attachNodePos_init(1:3,:)+...
        %                                             x( (6*(ibod-1)+1):(6*(ibod-1)+3) );
        % end
        
        Uc = current.wakeRatio*...
                 CurrentProfile(floatBody.attachNodePos(3,nodeList), current.vel, current.zlevel);
        %disp(Uc); % For debug
        Urel = [cosd(current.propDir);sind(current.propDir)]*Uc - x((ndof+2*(ibod-1)+1):(ndof+2*(ibod-1)+2));
        % disp(Urel); % For debug
        F_thisBody = abs(Urel).* Urel*...
                     (1/2*rho*floatBody.attachNodeCd(nodeList).*floatBody.attachNodeArea(nodeList))';
        F((2*(ibod-1)+1):(2*(ibod-1)+2)) = F_thisBody;
    end               
   % --------------------------------------
end