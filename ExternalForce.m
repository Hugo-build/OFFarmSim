function [Fhandle] = ExternalForce(type)
    switch nargin
        case 0
            % =============================================================
            error(['Input a type:: pullOut, ' ...
                          'decayF, ' ...
                          'regWave, '...
                          'irregWave, '...
                          'current' ] )
            % ============================================================
        case 1
            % =============================================================
            switch type
                case 'pullOut'    % <CASE 1>
                    Fhandle = @pullOutF;
                    %disp('Except "t<var>", need to define "Fcons<nx1> & Tramp<1>"')
                case 'decayF'     % <CASE 2>
                    Fhandle  = @decayF;
        
                case 'regWave'    % <CASE 3>
                    Fhandle = @regWaveF;
        
                case 'irregWave'  % <CASE 4>
                    Fhandle  = @irregWaveF;
        
                case 'currentOnly'    % <CASE 5>
                    Fhandle  = @currentF;

                case 'fluidDrag'
                    Fhandle  = @dragF;
                otherwise
                    warning(['Input a defined type:: pullOut, ' ...
                              'decayF, ' ...
                              'regWave, '...
                              'irregWave, '...
                              'currentOnly' ] )
            end
            % =============================================================

    end
end
