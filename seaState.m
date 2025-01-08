classdef seaState < handle
% ########################################################################
%
%
% LOGs ::
%                 
%  2024-07-23 -> * [V] create this class         
%  2024-07-25 -> * [V] create func "setupCurrent()"
%                  [V] create func "setupWave()"
%                  [V] finish regular wave case
%                  [V] irregular wave with Jonswap basic model
%                  [V] irregular wave with Sine method added
%                  [V] tested "setupCurrent()" and "setupWave()"
%
%
%
% ########################################################################
properties
    wind
    current
    regWave
    irregWave
end

methods
    function obj = seaState()
        fprintf('Using obj.setupWave() to set up a wave field\n')
        fprintf('Using obj.setupCurrent() to set up a current field\n')
    end

    function obj = setupWave(obj, iWaveMode, varargin)
    % ====================================================================
    % 
    % setupWave(iWaveMode) -> returns a regular wave struct with
    %                         iWaveMode == 1;
    %                         returns a irregular wave struct with
    %                         iWaveMode == 2;
    %
    % setupWave(iWaveMode,wavebasics) -> 
    %                          return waves with basic input variables
    %                          [amp, period] for regWave;
    %                          [Hs, Tp] or [Hs, Tp, gamma] for
    %                          irregular waves with Jonswap
    %                                   
    % ====================================================================
        % Default values
        p = inputParser;
        p.CaseSensitive = false;
        p.KeepUnmatched = true;
    
        % Common parameters
        addParameter(p, 'propDir', 0, @isnumeric);
    
        if iWaveMode == 1 % Regular wave
            addParameter(p, 'amp', [], @isnumeric);
            addParameter(p, 'period', [], @isnumeric);
        elseif iWaveMode == 2 % Irregular wave
            addParameter(p, 'Hs', [], @isnumeric);
            addParameter(p, 'Tp', [], @isnumeric);
            addParameter(p, 'gamma', 3.3, @isnumeric);
            addParameter(p, 'specType', 'Jonswap', @ischar);
        else
            error('Invalid wave mode. Use 1 for regular wave or 2 for irregular wave.');
        end
    
        parse(p, varargin{:});
    
        if iWaveMode == 1 % Regular wave
            if isempty(p.Results.amp) || isempty(p.Results.period)
                error('Amplitude (amp) and period must be provided for regular waves.');
            end
            obj.regWave = struct();
            obj.regWave.Za = p.Results.amp;
            obj.regWave.period = p.Results.period;
            obj.regWave.propDir = p.Results.propDir;
    
            % Calculate additional parameters
            obj.regWave.freq = 1 / obj.regWave.period;
            obj.regWave.omega = obj.regWave.freq * 2 * pi;
            g = 9.81; % acceleration due to gravity
            obj.regWave.k = obj.regWave.omega^2 / g;
            obj.regWave.kX = obj.regWave.k * cosd(obj.regWave.propDir);
            obj.regWave.kY = obj.regWave.k * sind(obj.regWave.propDir);
            obj.regWave.phase = 2 * pi * rand();
    
        elseif iWaveMode == 2 % Irregular wave
            if isempty(p.Results.Hs) || isempty(p.Results.Tp)
                error('Significant wave height (Hs) and peak period (Tp) must be provided for irregular waves.');
            end
            % Setup the struct "irregWave"
            obj.irregWave = struct();
            obj.irregWave.Hs = p.Results.Hs;
            obj.irregWave.Tp = p.Results.Tp;
            obj.irregWave.gamma = p.Results.gamma;
            obj.irregWave.propDir = p.Results.propDir;
            obj.irregWave.specType = p.Results.specType;

            % Calculate additional parameters
            obj.irregWave.dfreq    = 0.001;
            obj.irregWave.domega   = 2*pi*obj.irregWave.dfreq;
            obj.irregWave.omegaVec = 0.2:obj.irregWave.domega:2 ;                                        %<m x 1> Vector
            obj.irregWave.freqVec  = obj.irregWave.omegaVec./2/pi;                                       %<m x 1> Vector
            obj.irregWave.dirVec   = 0*pi/180;                                                           %<1 x n> Vector
            g = 9.81;  % acceleration due to gravity
            obj.irregWave.k  = obj.irregWave.omegaVec.^2/g;                                              %<m x 1> Vector
            obj.irregWave.kX = obj.irregWave.k .*cos(obj.irregWave.dirVec+obj.irregWave.propDir*pi/180); %<m x n> Matrix
            obj.irregWave.kY = obj.irregWave.k .*sin(obj.irregWave.dirVec+obj.irregWave.propDir*pi/180); %<m x n> Matrix
            % % -- Use index for dimensions -------------
            m = length(obj.irregWave.omegaVec);       %
            n = length(obj.irregWave.dirVec);         %
            % -----------------------------------------
            if obj.irregWave.specType == 'Jonswap'
               
               obj.irregWave.Szz = waveSpectrum(1, [obj.irregWave.Hs,...
                                                    obj.irregWave.Tp,...
                                                    obj.irregWave.gamma], obj.irregWave.omegaVec, 0);     %<m x 1> Vector
               obj.irregWave.SzzDir   = obj.irregWave.Szz*ones(1,n)/n;                                    %<m x n> Matrix
               obj.irregWave.ZaMat    = sqrt(2*obj.irregWave.SzzDir*obj.irregWave.domega);                %<m x n> Matrix
               obj.irregWave.omegaMat = repmat(obj.irregWave.omegaVec,1,length(obj.irregWave.dirVec));    %<m x n> Matrix
               obj.irregWave.phaseMat = 2*pi*rand([length(obj.irregWave.freqVec), ...
                                                   length(obj.irregWave.dirVec)]);                        %<m x n> Matrix

               % - Calculation for irregular wave ------------------------------- 
               obj.irregWave.ZaCal    = reshape(obj.irregWave.ZaMat,    [m*n,1]);
               obj.irregWave.omegaCal = reshape(obj.irregWave.omegaMat, [m*n,1]);
               obj.irregWave.kXCal    = reshape(obj.irregWave.kX,       [m*n,1]);
               obj.irregWave.kYCal    = reshape(obj.irregWave.kY,       [m*n,1]);
               obj.irregWave.phaseCal = reshape(obj.irregWave.phaseMat, [m*n,1]);
               % ----------------------------------------------------------------
            end
        end
    end %end of this function




    function obj = setupCurrent(obj, varargin)
        p = inputParser;
        p.CaseSensitive = false;
        p.KeepUnmatched = true;
    
        addParameter(p, 'vel',       [],       @(x) isnumeric(x) && numel(x) >= 2);
        addParameter(p, 'propDir',   0,        @isnumeric);
        addParameter(p, 'zlevel',    [0, -30], @(x) isnumeric(x) && numel(x) >= 2);
        addParameter(p, 'wakeRatio', [],       @isnumeric);
    
        parse(p, varargin{:});
    
        if isempty(p.Results.vel)
            error('Current velocity (vel) must be provided.');
        end

        if numel(p.Results.vel) ~= numel(p.Results.zlevel)
            error('The size of velocity does not match the level of current.')
        end
    
        obj.current = struct();
        obj.current.vel = p.Results.vel;
        obj.current.propDir = p.Results.propDir;
        obj.current.zlevel = p.Results.zlevel;
        
        if isempty(p.Results.wakeRatio)
            obj.current.wakeRatio = obj.current.vel(2) / obj.current.vel(1);
        else
            obj.current.wakeRatio = p.Results.wakeRatio;
        end
    
        % Handle any unmatched parameters
        unmatched = p.Unmatched;
        fields = fieldnames(unmatched);
        for i = 1:length(fields)
            obj.current.(fields{i}) = unmatched.(fields{i});
        end
    end% end of this function

end % END of methods

end % END of this class