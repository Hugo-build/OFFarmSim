function Elsys = structElsys(floatBody)
% ###########################################################################################
% This function is used for constructing a struct with all slender elements
% for calculating viscous fluid induced forces
%  ------------------------------------------------------------------------
%  Input --> floatBody(:) is an 'array of struct' 
%            |               should include attributes
%            |__attachNodePos_init
%            |__attachNodeCd
%            |__attachNodeArea
%            |__attachNodeVec
%            |__attachNodePos
%            |__ElType
%            |__ElIndex
%            |__type2node_L
%            |__type2node_R
%            |__posGlobal
%    
%
%  Output --> Elsys is a 'struct' should  include attributes
%             |__
%
% -------------------------------------------------------------------------
%  2024-05-06 -> 
%                
% ############################################################################################

nbod = length(floatBody);
ndof = 0;
for ibod = 1:nbod
    ndof = ndof + floatBody(ibod).calDoF;
end

Elsys = [];

Elsys.bodPos_globInit = zeros(3,nbod);

Elsys.attachNodePos_globInit = [];
Elsys.attachNodePos_loc      = []; 
Elsys.attachNodeCd           = [];
Elsys.attachNodeVec          = [];
Elsys.attachNodeArea         = [];

Elsys.nbod = nbod;
Elsys.nNodes4nbod   = 0;
Elsys.nNodesPerBod  = zeros(nbod,1);

Elsys.DoF_Tran     = [];
Elsys.DoF_Rot      = [];
Elsys.bod2DoF_Tran = zeros(nbod,3);
Elsys.bod2DoF_Rot  = zeros(nbod,3);

Elsys.Index_cylType = [];
Elsys.Index_netType = [];
Elsys.Els2bod = zeros(nbod,2);


% --- set up all attachNodes in the system -------------------------------
for ibod = 1:nbod
    Elsys.bodPos_globInit(:,ibod) = floatBody(ibod).posGlobal;
    Elsys.DoF_Tran = [Elsys.DoF_Tran, (6*(ibod-1)+1):(6*(ibod-1)+3) ];
    Elsys.DoF_Rot  = [Elsys.DoF_Rot,  (6*(ibod-1)+4):(6*(ibod-1)+6) ];
    
    Elsys.attachNodePos_globInit = [Elsys.attachNodePos_globInit, floatBody(ibod).attachNodePos_init(1:3,:) +...
                                    floatBody(ibod).posGlobal(1:3,:)]; 
                                    %-> dim::<nbod*3, nNodesPerbod>
    
    Elsys.attachNodePos_loc = [Elsys.attachNodePos_loc, floatBody(ibod).attachNodePos_init(1:3,:)];

    Elsys.attachNodeVec =  [Elsys.attachNodeVec, floatBody(ibod).attachNodeVec(1:3,:)];
    Elsys.attachNodeCd  =  [Elsys.attachNodeCd, floatBody(ibod).attachNodeCd(1,:)];
    Elsys.attachNodeArea = [Elsys.attachNodeArea, floatBody(ibod).attachNodeArea(1,:)];

    % ! should improve on this for unequal sized nodeList
    Elsys.nNodes4nbod = Elsys.nNodes4nbod + size(floatBody(ibod).attachNodePos_init,2);
    Elsys.nNodesPerBod(ibod) = size(floatBody(ibod).attachNodePos_init,2);
end
% --- set up node indexes ------------------------------------------------
for ibod = 1:nbod
    Elsys.bod2DoF_Tran(ibod,1:3) = (6*(ibod-1)+1):(6*(ibod-1)+3);
    Elsys.bod2DoF_Rot(ibod,1:3)  = (6*(ibod-1)+4):(6*(ibod-1)+6);

    Elsys.Els2bod(ibod,:)= [sum(Elsys.nNodesPerBod(1:ibod))-Elsys.nNodesPerBod(ibod)+1,...
                            sum(Elsys.nNodesPerBod(1:ibod)) ];
     
    leftIndex  = (Elsys.Els2bod(ibod,1)+floatBody(ibod).type2node_L("cylinder")-1);
    rightIndex = (Elsys.Els2bod(ibod,1)+floatBody(ibod).type2node_R("cylinder")-1);
    Elsys.Index_cylType  = [Elsys.Index_cylType,...
                            (leftIndex : rightIndex)];   

    leftIndex  = (Elsys.Els2bod(ibod,1)+floatBody(ibod).type2node_L("net")-1);
    rightIndex = (Elsys.Els2bod(ibod,1)+floatBody(ibod).type2node_R("net")-1);
    Elsys.Index_netType  = [Elsys.Index_netType,...
                            (leftIndex : rightIndex)]; 
end




end