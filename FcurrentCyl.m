function F = FcurrentCyl(t,x,floatBody,current)
% ####################################################



% ####################################################
nodeList = floatBody.type2node_L("cylinder"):floatBody.type2node_R("cylinder");
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
        %     floatBody(ibod).attachNodePos(1:3,:) = rotEular3D(x( (6*(ibod-1)+4):(6*(ibod-1)+6)) )*floatBody(ibod).attachNodePos_init(1:3,:)+...
        %                                             x( (6*(ibod-1)+1):(6*(ibod-1)+3) );
        % end
        
        Uc = current.wakeRatio*...
             CurrentProfile(floatBody.attachNodePos(3,nodeList), current.vel, current.zlevel);
        Urel  = [cosd(current.propDir);sind(current.propDir);0]*Uc - x((ndof+6*(ibod-1)+1):(ndof+6*(ibod-1)+3));
        Un = Urel-sum(Urel.*floatBody(ibod).attachNodeVec(:,nodeList), 1).*floatBody(ibod).attachNodeVec(:,nodeList);
        % disp(Un)
        Un_mod = sqrt(Un(1,:).^2 + Un(2,:).^2+ Un(3,:).^2);
        % disp(Un_mod)
        % vecProj = [sqrt(floatBody(ibod).attachNodeVec(2,:).^2 + floatBody(ibod).attachNodeVec(3,:).^2);...
        %            sqrt(floatBody(ibod).attachNodeVec(3,:).^2 + floatBody(ibod).attachNodeVec(1,:).^2);...
        %            sqrt(floatBody(ibod).attachNodeVec(1,:).^2 + floatBody(ibod).attachNodeVec(2,:).^2)];
        % disp(vecProj)


        F_thisBody = Un_mod.* Un*...
                     (1/2*rho*floatBody.attachNodeCd(nodeList).*floatBody.attachNodeArea(nodeList))';
        F((ndof*(ibod-1)+1):(ndof*(ibod-1)+3)) = F_thisBody;
    end               
   % --------------------------------------
end