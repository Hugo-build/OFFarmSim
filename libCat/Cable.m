classdef Cable < handle
% ########################################################################
%
%
% LOGs ::
%                 _
%  2024-06-02 -> | [V] node speration is done for joint between two segs
%                |_
%  2024-07-23 -> *[V] Fix some warnings regarding typos     
%  2024-07-24 -> *[V] Add Tmaxcat, Tproof, Tbreak as properties
% 
%
% ########################################################################

    % CABLE Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        Nseg                 % Number of segments
        NnodesPerSeg         % Number of nodes per segment
        Nnodes               % Number of nodes in total

        E                    % Elastic module
        A                    % cross sectional area
        w                    % weight per length
        s                    % segment length
        length               % total length
        touchDownSeg         % index for touch down segment

        X2F                  % inital designed X-distance from fairlead to anchor
        Z2F                  % inital designed Z-distance from fairlead to anchor
        F2B

        guessSol

        HH                   % Horizontal force tensor
        VV                   % Vertical force tensor
        SS                   % tensor of lifted length of touch down segment

        XX2anch              % tensor of X-distance from fairlead to anchor
        ZZ2anch              % tensor of Z-distance from fairlead to anchor

        XXF2F                % tensor of X-distance from fairlead to fairlead          
        ZZF2B                % tensor of Z-distance from fairlead to seabed 

        TmaxCat              % Maximum load for lifting to the anchor position
                             % <1x1>

        Tproof               % Proof load of material in linear material condition
                             % <1xNseg>

        Tbreak               % Breakload of material in linear material condition
                             % <1xNseg>

        shapeLoc             % <3xNnodes>
        shapeLoc_init        % <3xNnodes>

        info                 % information regarding material
    end
    


    methods
        % constuctor func
        function obj = Cable()
            fprintf("#############################################################################\n")
            fprintf("MAKING A CABLE LINE ... \n")
            fprintf("\n")
        end
        
        function obj = help(obj)
            fprintf("!\n")
        end

        % function for load-dis relationship calculation
        function obj =  loadDisCal(obj,config,NXstep)
            % --- Explanantion -------------------------------
            %   config :: the style of the cable
            %   NXstep :: the number of load-dis pairs needed
            % ------------------------------------------------
            
            switch nargin
                case 1
                    fprintf("Plz define a type of cable line ")
                case 2
                    NXstep = 30;
            end

            switch config
                % ###########################################################################################################
                case 1  % with anchor
                    % =============================
                    %        V                    %   
                    %     H__|                    %   
                    %         \                   %   
                    %          \                  %   
                    %           \                 %
                    %             \               %
                    %               \             %
                    %                 \ _ _ _ __  %
                    %                             %
                    %   z                         %
                    %   |__x                      %
                    % ==============================
                    syms H
                    if isempty(obj.touchDownSeg) 
                        disp('Plz tell the program the segment that starts to touch the bottom')
                    elseif isempty(obj.X2F)
                        disp('Plz give the distance from fairlead to anchor')
                    else
                        xVec = cell(obj.Nseg,1);
                        zVec = cell(obj.Nseg,1);
                        % ---Find the max Htension at fairlead --------------------------------
                        %    when the anchor is being lifted
                        V = obj.w(1:obj.touchDownSeg)*obj.s(1:obj.touchDownSeg)';
                        for i = 1:obj.Nseg
                            [xVec{i}, zVec{i}] = Catenary(H, ...
                            V+obj.w(i)*obj.s(i)-obj.w(1:i)*obj.s(1:i)',...
                            obj.w(i), obj.s(i), obj.E(i), obj.A(i));
                        end
                        eXF = -obj.X2F;
                        eZF = -obj.Z2F;
                        
                         for i = 1:obj.Nseg
                            eXF = eXF + xVec{i};
                            eZF = eZF + zVec{i};
                         end
                        
                        eqn_H = eZF==0;
                        sol_H = vpasolve(eqn_H,H);
                        if isempty(sol_H)
                            disp('Solution is not found !')
                            disp('Cannot determine a maximum-tensioned catenary shape!')
                        else
                            disp('Have found a maximum-tensioned catenary shape!')
                            Hmax = abs(double(sol_H))
                        end
                        obj.HH = linspace(1e4,Hmax,NXstep);
                        obj.SS = zeros(1,numel(obj.HH));
                        obj.XX2anch = zeros(1,numel(obj.HH));
                        obj.ZZ2anch = zeros(1,numel(obj.HH));
                        % ---------------------------------------------------------------------
                        
                        % --- Loop over reducing horizontal tension H -------------------------
                        for iH = 1:numel(obj.HH)
                            syms S
                            V = obj.w(obj.touchDownSeg)*S + ...
                            obj.w(1:obj.touchDownSeg-1)*obj.s(1:obj.touchDownSeg-1)';
                            
                            for i = 1:obj.Nseg
                                if i == obj.touchDownSeg
                                    [xVec{i}, zVec{i}] = Catenary(obj.HH(iH), ...
                                    V+obj.w(i)*obj.s(i)-obj.w(1:i)*obj.s(1:i)',...
                                    obj.w(i), S, obj.E(i), obj.A(i));
                                else
                                    [xVec{i}, zVec{i}] = Catenary(obj.HH(iH), ...
                                    V+obj.w(i)*obj.s(i)-obj.w(1:i)*obj.s(1:i)',...
                                    obj.w(i), obj.s(i), obj.E(i), obj.A(i));
                                end
                            end
                            
                            eZF = -obj.Z2F;   
                            eXF = 0;
                            for i = 1:obj.Nseg
                                eZF = eZF + zVec{i};
                                eXF = eXF + xVec{i};
                            end
                            
                            eqn_S = eZF==0;
                            sol_S = vpasolve(eqn_S,S, [0 obj.length]);
                            
                            if isempty(sol_S)
                                disp(['Solution of lifted length is not found for the given Htension=' num2str(obj.HH(iH)/1000) '[kN]'])
                                fprintf("tension might be too small\n")
                            else
                                obj.SS(iH) = double(sol_S);
                                obj.XX2anch(iH) = subs(eXF, S, double(sol_S)) + obj.length-...
                                              obj.SS(iH) - sum(obj.s(1:obj.touchDownSeg-1));
                                obj.ZZ2anch(iH) = subs(eZF, S, double(sol_S));
                            end
                        end
                        
                        obj.HH(obj.SS==0)=0;
                        % !!! FOR DEBUG !!!
                        %HH               %!          
                        %SS               %!
                        %XX2anch          %!  
                        %ZZ2anch          %!
                        % !!!!!!!!!!!!!!!!!
                        if obj.touchDownSeg == 1
                            obj.VV = obj.w(obj.touchDownSeg)*obj.SS;
                        else
                            obj.VV = obj.w(1:obj.touchDownSeg-1)*obj.s(1:obj.touchDownSeg-1)' + obj.w(obj.touchDownSeg)*obj.SS;
                        end
                        obj.TmaxCat = sqrt(max(obj.HH).^2 + max(obj.VV).^2);
                        

                        obj.s(obj.touchDownSeg) = interp1(unique(obj.XX2anch), unique(obj.SS), obj.X2F);
                        H0 = interp1(unique(obj.XX2anch), unique(obj.HH), obj.X2F);
                        V0 = obj.w(1:obj.touchDownSeg)*obj.s(1:obj.touchDownSeg)';

                        disp('------------------ Initial solution found -----------------------------')
                        disp(['Horizontal distance fairlead to anchor == ' num2str(obj.X2F) ' [m]'])
                        disp(['Vertictal distance fairlead to anchor  == ' num2str(obj.Z2F) ' [m]'])
                        disp(['Horizontal tension at fairlead    == ' num2str(H0) ' [N]'] )
                        disp(['Vertical tension at fairlead 1    == ' num2str(V0)  ' [N]'])

                        disp(['Total tension at fairlead 1    == ' num2str(sqrt(H0^2 + V0^2))  ' [N]'])
                        disp('-----------------------------------------------------------------------')

                        

                    end
                % ###########################################################################################################        
                case 2
                    % ===========================
                    %    V                       %
                    % H__|                       %
                    %     \                      %
                    %      \               /     % 
                    %       \             /      %
                    %         \         /        %
                    %           \ _ _ /          %
                    %                            %
                    %   z                        %
                    %   |__x                     %
                    % ============================
                    syms H V
                    xVec = cell(obj.Nseg,1);
                    zVec = cell(obj.Nseg,1);
                    
                    for i = 1:obj.Nseg
                        [xVec{i}, zVec{i}] = Catenary(H, ...
                        V+obj.w(i)*obj.s(i)-obj.w(1:i)*obj.s(1:i)',...
                        obj.w(i), obj.s(i), obj.E(i), obj.A(i));
                    end
                    Gravity = obj.w(1:end)*obj.s(1:end)';
                    % --- Solve the range of cable tension vs. fairleads' relative positions ------
                    obj.XXF2F = linspace(0.6*obj.length,0.99*obj.length, NXstep);
                    obj.HH    = zeros(2,length(obj.XXF2F));
                    obj.VV    = zeros(2,length(obj.XXF2F));
                    obj.SS    = zeros(2,length(obj.XXF2F));
                    obj.ZZF2B = zeros(2,length(obj.XXF2F));
                    for iX = 1:length(obj.XXF2F)
                        eXF = -obj.XXF2F(iX); eZF = -obj.Z2F;
                        for i = 1:obj.Nseg
                            eXF = eXF + xVec{i};
                            eZF = eZF + zVec{i};
                        end
                        eqns = [eXF == 0; eZF == 0];
                        sols = vpasolve(eqns, obj.guessSol);
                        if isempty(sols.H)
                            disp('Solution is not found !')
                            disp('Cannot determine an initial catenary shape!')
                            disp('suggest changing guessed solution range!')
                        else
                            obj.HH(1,iX) = double(sols.H);
                            obj.HH(2,iX) = double(sols.H);
                            
                            obj.VV(1,iX) = double(sols.V);
                            obj.VV(2,iX) = Gravity -  obj.VV(1,iX);
                        end
                        clear eXF eZF
                    end
                    
                    % !!! FOR DEBUG !!!
                    %HH               %!          
                    %VV               %!
                    %XXF2F            %!  
                    % !!!!!!!!!!!!!!!!!

                    obj.TmaxCat = sqrt(max(obj.HH,[],2).^2 + max(obj.VV,[],2).^2);

                    k = find(obj.HH(1,:));
                    H0 = interp1(unique(obj.XXF2F(k)), unique(obj.HH(1,k)), obj.X2F);
                    if obj.Z2F == 0
                        V0 = 1/2*obj.w*obj.s';
                    else
                        V0 = interp1(unique(obj.XXF2F(k)), unique(obj.VV(1,k)), obj.X2F);
                    end
                    clear k

                    if H0<0 || V0<0
                        disp('Negative solutions :: plz examine') 
                        disp('    |_______ 1-Buoyancy and gravity setup may be not approperiate !')
                        disp('    |_______ 2-Intial positions of fairleads  may be not approperiate !')
                    else
                        disp('------------------ Initial solution found -----------------------------')
                    
                        disp(['horizontal distance between fairleads == ' num2str(obj.X2F) ' [m]'])
                        disp(['Horizontal tension at fairlead 1  == ' num2str(H0) ' [N]'] )
                        disp(['Horizontal tension at fairlead 2  == ' num2str(H0) ' [N]'] )
                        disp(['Vertical tension at fairlead 1    == ' num2str(V0)  ' [N]'])
                        disp(['Vertical tension at fairlead 2    == ' num2str(Gravity - V0) ' [N]'])
                    
                        disp(['Total tension at fairlead 1    == ' num2str(sqrt(H0^2 + V0^2))  ' [N]'])
                        disp(['Total tension at fairlead 2    == ' num2str(sqrt(H0^2 + (Gravity - V0)^2)) ' [N]'])
                    
                        disp('-----------------------------------------------------------------------')

                    end
            end  % switch case end
        end % This function end
        





        % function for multi-segment catenary shape 2D profile calculation
        function obj =  shapeCal(obj,config,X2F_t)
            switch config
                % ########################################################################################################### 
                case 1
                    switch nargin
                        case 1
                            fprintf("Plz define a type of cable line ")
                        case 2
                            obj.s(obj.touchDownSeg) = interp1(unique(obj.XX2anch), unique(obj.SS), obj.X2F);
                            H0 = interp1(unique(obj.XX2anch), unique(obj.HH), obj.X2F);
                            V0 = obj.w(1:obj.touchDownSeg)*obj.s(1:obj.touchDownSeg)';
                        case 3
                            obj.s(obj.touchDownSeg) = interp1(unique(obj.XX2anch), unique(obj.SS), X2F_t);
                            H0 = interp1(unique(obj.XX2anch), unique(obj.HH), obj.X2F);
                            V0 = obj.w(1:obj.touchDownSeg)*obj.s(1:obj.touchDownSeg)';
                    end

                    shapeLoc = zeros(3,obj.Nnodes);
                    % --- Calculate Catenary shape ----------------------------------------
                    s = linspace(0,obj.s(1),obj.NnodesPerSeg(1));
                    for iseg = 1:obj.Nseg
                        endNodes = [sum(obj.NnodesPerSeg(1:iseg)) - obj.NnodesPerSeg(iseg) + 1, ...
                                    sum(obj.NnodesPerSeg(1:iseg))];
                        if iseg > 1
                            s_thisSeg = linspace(sum(obj.s(1:iseg-1)),sum(obj.s(1:iseg)),obj.NnodesPerSeg(iseg)+1);
                            s = [s, s_thisSeg(2:end)];
                        end
                
                        for is = endNodes(1):1:endNodes(2)
                            [xOut, zOut] = Catenary(H0, ...
                                V0+obj.w(iseg)*obj.s(iseg)-obj.w(1:iseg)*obj.s(1:iseg)',...
                                obj.w(iseg), s(is)-s(endNodes(1)), obj.E(iseg), obj.A(iseg));
                            if iseg == 1
                                shapeLoc(1,is) = xOut ;
                                shapeLoc(3,is) = zOut ;
                            else
                                shapeLoc(1,is) = xOut +  shapeLoc(1,endNodes(1)-1);
                                shapeLoc(3,is) = zOut +  shapeLoc(3,endNodes(1)-1);
                            end
                        end
                    end
                    
                    if obj.length>sum(obj.s(1:end))
                        obj.shapeLoc = [shapeLoc, [obj.length-sum(obj.s(1:end))+shapeLoc(1,endNodes(2));...
                                                   0;...
                                                  -abs(obj.Z2F)]];
                    else
                        obj.shapeLoc = shapeLoc; 
                    end
                    clear shapeLoc

                
                % ########################################################################################################### 
                case 2
                    switch nargin
                        case 1
                            fprintf("Plz define a type of cable line ")
                        case 2
                            k = find(obj.HH(1,:));
                            H0 = interp1(unique(obj.XXF2F(k)), unique(obj.HH(1,k)), obj.X2F);
                            if obj.Z2F == 0
                                V0 = 1/2*obj.w*obj.s';
                            else
                                V0 = interp1(unique(obj.XXF2F(k)), unique(obj.VV(1,k)), obj.X2F);
                            end
                            clear k
                        case 3
                            k = find(obj.HH(1,:));
                            H0 = interp1(unique(obj.XXF2F(k)), unique(obj.HH(1,k)), X2F_t);
                            if obj.Z2F == 0
                                V0 = 1/2*obj.w*obj.s';
                            else
                                V0 = interp1(unique(obj.XXF2F(k)), unique(obj.VV(1,k)), X2F_t);
                            end
                            clear k
                    end

                    shapeLoc = zeros(3,obj.Nnodes);
                    % --- Calculate Catenary shape---------------------------------------
                    s = linspace(0,obj.s(1),obj.NnodesPerSeg(1));
                    for iseg = 1:obj.Nseg
                            endNodes = [sum(obj.NnodesPerSeg(1:iseg)) - obj.NnodesPerSeg(iseg) + 1, ...
                                        sum(obj.NnodesPerSeg(1:iseg))];
                            if iseg > 1
                                s_thisSeg = linspace(sum(obj.s(1:iseg-1)),sum(obj.s(1:iseg)),obj.NnodesPerSeg(iseg)+1);
                                s = [s, s_thisSeg(2:end)];
                            end
                
                            for is = endNodes(1):1:endNodes(2)
                                [xOut, zOut] = Catenary(H0, ...
                                    V0+obj.w(iseg)*obj.s(iseg)-obj.w(1:iseg)*obj.s(1:iseg)',...
                                    obj.w(iseg), s(is)-s(endNodes(1)), obj.E(iseg), obj.A(iseg));
                                if iseg == 1
                                    shapeLoc(1,is) = xOut ;
                                    shapeLoc(3,is) = zOut ;
                                else
                                    shapeLoc(1,is) = xOut +  shapeLoc(1,endNodes(1)-1);
                                    shapeLoc(3,is) = zOut +  shapeLoc(3,endNodes(1)-1);
                                end
                            end
                    end
                    obj.shapeLoc = shapeLoc; clear shapeLoc

            end % switch case end
        end% This function end


        
        % FUNCTION for fitting the load-dis relationship into polynomials
        function obj = polyFit(obj,config,Npoly)
            switch nargin
                case 1
                    fprintf("Plz define a type of cable line \n")
                    fprintf(" 1 for anchored line \n")
                    fprintf(" 2 for anchored line \n")

                case 2
                    C = polyfit(obj.XX2anch, obj.HH, 3);
                case 3
                    C = polyfit(obj.XX2anch, obj.HH, Npoly);

            end% switch nargin end
           
        end% This function end

        function obj = getInfo(obj)
            obj.info = ['mass=' num2str(obj.w/9.81) ' [kg] | ' ...
                        'length=' num2str(obj.length) ' [m]'];
        end
     

    end % End of method in this class
end % End of this class

