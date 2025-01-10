function F = Fdrag(t,x,floatBody,current,wave)
% ###########################################################################################
% This function is used for calculating the general drag force
% on the frame of a ocean structure. 
%
% 2024-02-24 -> update calculation on both cylindrical
%               elements & netting elements
% 2024-02-25 -> compare zero wave case with func"FcurrentCyl" and func 
%               func"FcurrentNet" and func "Fcurrrent" [V] 
% 2024-03-02 -> compare RAO of surge,heave and pitch, using regular wave
%               getting OK results 
%               compared to  'Jin et al.(2021)'
%                              |__ https://doi.org/10.1016/j.marstruc.2021.103017
% 
%
% ############################################################################################

% --- fluid  drag --------------------
rho = 1025; g = 9.81;
nbod = length(floatBody);
ndof = length(x)/2;
F = zeros(ndof,1);

for ibod = 1:nbod
    floatBody(ibod).attachNodePos(1:3,:) = floatBody(ibod).attachNodePos_init(1:3,:) +...
                                           floatBody(ibod).posGlobal(1:3,:) +...
                                           x( (6*(ibod-1)+1):(6*(ibod-1)+3) );
                                  

    Uc = currentProfile(floatBody(ibod).attachNodePos(3,:), current.vel, current.zlevel);
    
    Uwave_XY = (wave.omegaCal.*wave.ZaCal)'* ...
               sin(-wave.omegaCal*t + ...
               [wave.kXCal,wave.kYCal]*[floatBody(ibod).attachNodePos(1,:);...
                                        floatBody(ibod).attachNodePos(2,:)] + wave.phaseCal).*...
                                       exp(4*pi^2/10^2/g * floatBody(ibod).attachNodePos(3,:));

    Uwave_Z = (wave.omegaCal.*wave.ZaCal)'* ...
              cos(-wave.omegaCal*t + ...
              [wave.kXCal,wave.kYCal]*[floatBody(ibod).attachNodePos(1,:);...
                                       floatBody(ibod).attachNodePos(2,:)] + wave.phaseCal).*...
                                      exp(4*pi^2/10^2/g * floatBody(ibod).attachNodePos(3,:));
    % -----------------
    % disp(Uwave_XY) %!
    % disp(Uwave_Z)  %!
    % -----------------
    Ufluid = [cosd(current.propDir);sind(current.propDir);0]*Uc + ...
             [[cosd(wave.propDir); sind(wave.propDir)]*Uwave_XY;Uwave_Z];
    Urel = Ufluid*current.wakeRatio-x((ndof+6*(ibod-1)+1):(ndof+6*(ibod-1)+3));
    %--------------
    % disp(Urel) %!
    %--------------
    F_thisBody = zeros(3,1);
    M_thisBody = zeros(3,1);
   
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
        % F_allCylEls_thisBod = Un_mod.* Un.*...
        %             (1/2*rho*floatBody(ibod).attachNodeCd(nodeList).*floatBody(ibod).attachNodeArea(nodeList));
        F_thisBody = F_thisBody+ Un_mod.* Un*...
                    (1/2*rho*floatBody(ibod).attachNodeCd(nodeList).*floatBody(ibod).attachNodeArea(nodeList))';
        M_thisBody = M_thisBody + cross(floatBody(ibod).attachNodePos_init(1:3,nodeList),Un_mod.* Un)*...
                    (1/2*rho*floatBody(ibod).attachNodeCd(nodeList).*floatBody(ibod).attachNodeArea(nodeList))'; % based on local coordinates
        
        % ............................................................................................................
    end
    
    if isKey(floatBody(ibod).type2node_L,"net")
        % ............................................................................................................
        % declare the node index for Netting elements
        nodeList = floatBody(ibod).type2node_L("net"):floatBody(ibod).type2node_R("net");
        Ud = Urel(:,nodeList); 
        Ud_mod = sqrt(Ud(1,:).^2 + Ud(2,:).^2+ Ud(3,:).^2);
        ed = Ud./Ud_mod;
        ed(isnan(ed)) = 0;
        % --------------------------------------------------
        % disp(ed)                                        %!
        % disp(floatBody(ibod).attachNodeVec(:,nodeList)) %!
        % --------------------------------------------------

        cosTheta = dot(ed, floatBody(ibod).attachNodeVec(:,nodeList));
        % ----------------------------
        % disp(size(cosTheta))      %!
        % disp(cosTheta')           %!
        % ----------------------------

        Sn = 0.162;
        [Cd, Cl] = netHydroVar(cosTheta, Sn, 1); % Varing Cd and Cl 
                                                 % due to that the inlet 
                                                 % velocity direction is 
                                                 % changing with wave particle 
                                                 % circulations
        % ----------------
        % disp(Cd)      %!
        % disp(Cl)      %!
        % ----------------
        % F_allNetEls_thisBod = Ud_mod.*Ud.*...
        %              (1/2*rho*Cd.*floatBody(ibod).attachNodeArea(nodeList));

        
        F_thisBody = F_thisBody + Ud_mod.*Ud*...
                     (1/2*rho*Cd.*floatBody(ibod).attachNodeArea(nodeList))';
        M_thisBody = M_thisBody + cross(floatBody(ibod).attachNodePos_init(1:3,nodeList),Ud_mod.*Ud)*...
                     (1/2*rho*Cd.*floatBody(ibod).attachNodeArea(nodeList))';
        
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
        % ............................................................................................................
    end


   F((6*(ibod-1)+1):(6*(ibod-1)+3)) = F_thisBody;
   F((6*(ibod-1)+4):(6*(ibod-1)+6)) = M_thisBody;
end

% -------------------------------------
end