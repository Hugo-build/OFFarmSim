function [K_omega_real, omega] = retard_t2w(k_t, t, omegaSpan, varargin)
% -------------------------------------------------------------------------
% Calculates the retardation function in frequency domain from time domain
%
% Inputs:
%   k_t: Retardation function in time domain
%   t: Time vector
%   omegaSpan: Frequency span for calculation
%   Name-Value Pairs:
%     'EnablePlots': Flag to enable plotting (default: false)
%     'NumInterpPoints': Number of interpolation points (default: 1000)
%
% Outputs:
%   K_omega_real: Retardation function in frequency domain
%   omega: Frequency vector
%
% -------------------------------------------------------------------------

% Set up input parser
p = inputParser;
addRequired(p, 'K_t', @isnumeric);
addRequired(p, 't', @isnumeric);
addRequired(p, 'OmegaSpan', @isnumeric);
addParameter(p, 'EnablePlots', false, @islogical);
addParameter(p, 'NumInterpPoints', 1000, ...
             @(x) isnumeric(x) && isscalar(x) && x > 0);

parse(p, k_t, t, omegaSpan, varargin{:}) % parse the inputs
% Extract parsed values
enablePlots = p.Results.EnablePlots;
numInterpPoints = p.Results.NumInterpPoints;

% Find Degrees of Freedom
numDDoF = size(k_t, 2);     % [nDoF x nDoF]
numDoF = sqrt(numDDoF);     % [nDoF]

% Check if numDDoF and numDoF are integers
assert(mod(numDDoF, 1) == 0 && mod(numDoF, 1) == 0, ...
       'numDDoF and numDoF must be integers');

omega = omegaSpan(:); % should be a column of vector

% Interpolation
t1 = linspace(t(1), t(end), numInterpPoints); % Interpolate over intgration
                                              % times
t1 = t1(:)';
k_t1 = interp1(t, k_t, t1, 'linear', 'extrap');

dt1 = t1(2) - t1(1); % Calculate time step

% Perform FFT on the time-domain retardation function
K_omega_real= cos(omega*t1) * k_t1 * dt1; %  [mx1]x[1xn]x[nx1] = [mx1]

% Plot if enabled
if enablePlots
    load("DDoFname.mat");
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    figure;
    for iDDoF = 1:numDDoF
        if any(K_omega_real(:, iDDoF) ~= 0)
            subplot(numDoF, numDoF, iDDoF)
            plot(omega, K_omega_real(:, iDDoF), 'LineWidth', 1.2);
            xlabel('\omega (rad/s)');
            ylabel('K(\omega)');
            title(DDoFname(iDDoF))
            grid on;
        end
    end
    sgtitle('Retardation Function in Frequency Domain');
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
end

fprintf('----------------------------------------------------------------\n')
fprintf('discrete time domain kernal ==> discrete freq-domain kernal\n')

end