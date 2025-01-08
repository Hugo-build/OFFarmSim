function F = FdragNB_v2(t,x, Elsys, current, wave)

% ###########################################################################################
% This function is used for calculating the general drag force
% on the frame of multiple ocean structure. 
%
%    !!  NB--> N Body  !!
%
%  2024-04-25 -> *copy from Fdrag().
%  
%                 _
%                | *test with struct <floatBody, current, wave>.
%  2024-05-03 -> | *Deficiency exists: size of attachNode should be the same
%                |  for each body in this case.
%                | *Created index list for identifying all nodes that are
%                |  cylinderal Morison elements or screen net elements
%                | ! 2do: combine nodeVec, nodeCd and etc. [V]
%                |_
%
%                 _ 
%  2024-05-05 -> | *Change to element wise calculation of drag force at each
%                |  descitized nodes. 
%                | * Speed up from func@Fdrag 0.038s --> 0.023 per call.
%                | ! 2do: compare results with @Fdrag(). [V]
%                |        check all attributes that are needed. [V]
%                |_
%
%                 _
%  2024-05-06 -> | *Speed up from func@Fdrag by saving 25% cpu time
%                |_*Compared to have same outputs asfunc@Fdrag
%
%                 _
%  2024-05-07 -> | *Corrected eKz term from 1st ver
%                | *Improve calculation efficiency by assemble all terms in
%                |  one calculation
%                |_
%
% 
%                
% ############################################################################################

rho = 1025; g = 9.81;
nbod = Elsys.nbod;
ndof = length(x)/2;

F = zeros(ndof,1); % Initialization of Output, dimension of which is <ndofx1>

% --- update all attachNodes' global position in the system --------------
attachNodePos = Elsys.attachNodePos_globInit;
for ibod = 1:nbod
    attachNodePos(1:3,Elsys.Els2bod(ibod,1):Elsys.Els2bod(ibod,2)) = attachNodePos(1:3,Elsys.Els2bod(ibod,1):Elsys.Els2bod(ibod,2))+...
                                                                 x(Elsys.bod2DoF_Tran(ibod,:));
    
end

% --- set up velocities --------------------------------------------------
% Uc = zeros(1,Elsys.nNodes4nbod);
% Uwave_XY
% Uwave_Z

Uc = currentProfile(attachNodePos(3,:), current.vel, current.zlevel);

% _____! improve on this !
%     |
%     V 
omegaZa = (wave.omegaCal.*wave.ZaCal)';
omegat_Kxy_phase = -wave.omegaCal*t + ...
               [wave.kXCal,wave.kYCal]*[attachNodePos(1,:);...
                                        attachNodePos(2,:)] + wave.phaseCal;
wave.k = wave.k(:);
eKz = exp(wave.k * attachNodePos(3,:));

Uwave_XY = omegaZa*(sin(omegat_Kxy_phase).*eKz);
Uwave_Z  = omegaZa*(cos(omegat_Kxy_phase).*eKz);

Ufluid = [cosd(current.propDir);sind(current.propDir);0]*Uc + ...
         [[cosd(wave.propDir); sind(wave.propDir)]*Uwave_XY;Uwave_Z];

Urel = Ufluid;
for ibod = 1:nbod
    Urel(1:3,Elsys.Els2bod(ibod,1):Elsys.Els2bod(ibod,2)) = Ufluid(1:3,Elsys.Els2bod(ibod,1):Elsys.Els2bod(ibod,2))*current.wakeRatio-...
                                                            x(ndof+Elsys.bod2DoF_Tran(ibod,:));
end


% =======================================================================
%              For Forces on cylinderal elements
% =======================================================================

    % .................................................................
    % declare the node index for cylindric slender elements
    % calculate the nodal normal velocity for cylindric slender elements
    Un = Urel(:,Elsys.Index_cylType)-sum(Urel(:,Elsys.Index_cylType).*...
         Elsys.attachNodeVec(:,Elsys.Index_cylType), 1).* Elsys.attachNodeVec(:,Elsys.Index_cylType);

    % calculate the module of nodal normal velocity for cylindric slender elements
    Un_mod = sqrt(Un(1,:).^2 + Un(2,:).^2+ Un(3,:).^2);

    % calculate the drag force for cylindric slender elements
    % F_cyls = Un_mod.* Un.*...
    %          (1/2*rho*Elsys.attachNodeCd(Elsys.Index_cylType).*Elsys.attachNodeArea(Elsys.Index_cylType));
    % M_cyls = cross(Elsys.attachNodePos_loc(1:3,Elsys.Index_cylType),Un_mod.* Un).*...
    %          (1/2*rho*Elsys.attachNodeCd(Elsys.Index_cylType).*Elsys.attachNodeArea(Elsys.Index_cylType));
    % based on local coordinates
    % ...................................................................
  

% =======================================================================
%           For Forces on tensioned net panel elements
% =======================================================================
    % ...................................................................
    % declare the node index for Netting elements
    % calculate the nodal normal velocity for cylindric slender elements
    Ud = Urel(:,Elsys.Index_netType); 
    Ud_mod = sqrt(Ud(1,:).^2 + Ud(2,:).^2+ Ud(3,:).^2);
    ed = Ud./Ud_mod;
    ed(isnan(ed)) = 0; %exclude the case where the velocity module is zero
    % --------------------------------------------------
    % disp(ed)                                        %!
    % disp(floatBody(ibod).attachNodeVec(:,nodeList)) %!
    % --------------------------------------------------
    cosTheta = dot(ed, Elsys.attachNodeVec(:,Elsys.Index_netType));
    % ----------------------------
    % disp(size(cosTheta))      %!
    % disp(cosTheta')           %!
    % ----------------------------
    Sn = 0.162;
    [Cd, Cl] = netHydroVar(cosTheta, Sn, 1); % Varing Cd and Cl 
                                             % due to that the inlet 
                                             % velocity direction is 
                                             % changing with wave particle 
    % ----------------
    % disp(Cd)      %!
    % disp(Cl)      %!
    % ----------------
    % F_nets =  Ud_mod.*Ud.*...
    %           (1/2*rho*Cd.*Elsys.attachNodeArea(Elsys.Index_netType));
    % M_nets =  cross(Elsys.attachNodePos_loc(1:3,Elsys.Index_netType),Ud_mod.*Ud).*...
    %           (1/2*rho*Cd.*Elsys.attachNodeArea(Elsys.Index_netType));
 
    %   -------------------------------------------------
    %  !! If Lift force is significant, can enable this !!
    %   -------------------------------------------------
    %                         ||
    %                         ||
    %                        _||_
    %                        \  /
    %                         \/
    % % calculate the cross product of the unit vector of fluid
    % % veclocity and unit vector of the normal direction of the 
    % % net panel
    % edXen = cross(ed,floatBody(ibod).attachNodeVec(:,nodeList));
    % % calculate the unit vector of lift force
    % el = cross(edXen, ed);
    % % calculate the contributions of the lift force
    % F_thisBody = F_thisBody + Ul_mod.^2.*el*...
    %                 (1/2*rho*Cl.*floatBody(ibod).attachNodeArea(nodeList))';
    % ...................................................................

    % F_allEls = zeros(3,Elsys.nNodes4nbod);
    % F_allEls(1:3,Elsys.Index_cylType) = F_cyls;
    % F_allEls(1:3,Elsys.Index_netType) = F_nets;
    % 
    % M_allEls = zeros(3,Elsys.nNodes4nbod);
    % M_allEls(1:3,Elsys.Index_cylType) = M_cyls;
    % M_allEls(1:3,Elsys.Index_netType) = M_nets;

    Elsys.attachNodeCd(Elsys.Index_netType) = Cd;
    Ucal     = zeros(3,Elsys.nNodes4nbod);
    Ucal_mod = zeros(1,Elsys.nNodes4nbod);

    Ucal(1:3,Elsys.Index_cylType)   = Un;
    Ucal_mod(1,Elsys.Index_cylType) = Un_mod;
    Ucal(1:3,Elsys.Index_netType)   = Ud;
    Ucal_mod(1,Elsys.Index_netType) = Ud_mod;
    

    % F_allEls =  Ucal_mod.*Ucal.*...
    %           (1/2*rho*Elsys.attachNodeCd.*Elsys.attachNodeArea);
    % M_allEls =  cross(Elsys.attachNodePos_loc(1:3,:),Ucal_mod.*Ucal).*...
    %           (1/2*rho*Elsys.attachNodeCd.*Elsys.attachNodeArea);


    UUmod = Ucal_mod.*Ucal;
    halvRhoCddA = 1/2*rho*Elsys.attachNodeCd.*Elsys.attachNodeArea;
    F_allEls = UUmod.*halvRhoCddA;
    M_allEls = cross(Elsys.attachNodePos_loc(1:3,:),UUmod).*halvRhoCddA;


    for ibod = 1:nbod
        F(Elsys.DoF_Tran(3*(ibod-1)+1:3*(ibod-1)+3)) = sum(F_allEls(1:3,Elsys.Els2bod(ibod,1):1:Elsys.Els2bod(ibod,2)),2);
        F(Elsys.DoF_Rot(3*(ibod-1)+1:3*(ibod-1)+3))  = sum(M_allEls(1:3,Elsys.Els2bod(ibod,1):1:Elsys.Els2bod(ibod,2)),2);
    end

end

