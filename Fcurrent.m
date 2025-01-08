function F = Fcurrent(t,x,floatBody,current)

% ##########################################################
% This function is used for calculating the current force
% on the frame and other componnets of a ocean structure. 
%
%
% ##########################################################

% --- Current drag --------------------
rho = 1025;
nbod = length(floatBody);
ndof = length(x)/2;
F = zeros(ndof,1);

for ibod = 1:nbod
    floatBody(ibod).attachNodePos(1:3,:) = floatBody(ibod).attachNodePos_init(1:3,:) +...
                                                    x( (6*(ibod-1)+1):(6*(ibod-1)+3) );
    Uc = current.wakeRatio*...
         currentProfile(floatBody(ibod).attachNodePos(3,:), current.vel, current.zlevel);
    
    Urel  = [cosd(current.propDir);sind(current.propDir);0]*Uc - x((ndof+6*(ibod-1)+1):(ndof+6*(ibod-1)+3));
    F_thisBody = zeros(3,1);
    if isKey(floatBody(ibod).type2node_L,"cylinder")
        % ............................................................................................................
        % declare the node index for cylindric slender elements
        nodeList = floatBody(ibod).type2node_L("cylinder"):floatBody(ibod).type2node_R("cylinder");

        % calculate the nodal normal velocity for cylindric slender elements
        Un = Urel(:,nodeList)-sum(Urel(:,nodeList).*floatBody(ibod).attachNodeVec(:,nodeList), 1).*...
                                  floatBody(ibod).attachNodeVec(:,nodeList);

        % calculate the module of nodal normal velocity for cylindric slender elements
        Un_mod = sqrt(Un(1,:).^2 + Un(2,:).^2+ Un(3,:).^2);

        % calculate the drag force for cylindric slender elements
        F_thisBody = F_thisBody+ Un_mod.* Un*...
                    (1/2*rho*floatBody(ibod).attachNodeCd(nodeList).*floatBody(ibod).attachNodeArea(nodeList))';
        % 
        % ............................................................................................................
    end 
    
    if isKey(floatBody(ibod).type2node_L,"net")
        % ............................................................................................................
        % declare the node index for Netting elements
        nodeList = floatBody(ibod).type2node_L("net"):floatBody(ibod).type2node_R("net");
        Ud = Urel(:,nodeList);
        % disp(Ud)
        Ud_mod = sqrt(Ud(1,:).^2 + Ud(2,:).^2+ Ud(3,:).^2);
        F_thisBody = F_thisBody + Ud_mod.*Ud*...
                     (1/2*rho*floatBody(ibod).attachNodeCd(nodeList).*floatBody(ibod).attachNodeArea(nodeList))';

        % ............................................................................................................
    end

    F((6*(ibod-1)+1):(6*(ibod-1)+3)) = F_thisBody;
end


end