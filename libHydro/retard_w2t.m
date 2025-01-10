function [k_t, t] = retard_w2t(K_omega, omega, tspan, varargin)
% -------------------------------------------------------------------------
% Calculates the retardation function in time domain from frequency domain
%
% Inputs:
%   K_omega: Retardation function in frequency domain
%   omega: Frequency vector
%   tspan: Time span for retardation calculation
%   Name-Value Pairs:
%     'EnablePlots': Flag to enable plotting (default: false)
%
% Outputs:
%   k_t: Retardation function in time domain
%   t: Time vector
%
% -------------------------------------------------------------------------

% Set up input parser
p = inputParser;
addRequired(p, 'K_omega', @isnumeric);
addRequired(p, 'omega', @isnumeric);
addRequired(p, 'tspan', @isnumeric);
addParameter(p, 'EnablePlots', false, @islogical);

% Parse inputs
parse(p, K_omega, omega, tspan, varargin{:});

% Extract parsed values
enablePlots = p.Results.EnablePlots;

% Find Degrees of Freedom
numDDoF = size(K_omega, 2); % [nDoF x nDoF]
numDoF = sqrt(numDDoF);     % [nDoF]

% Check if numDDoF and numDoF are integers
assert(mod(numDDoF, 1) == 0 && mod(numDoF, 1) == 0, 'numDDoF and numDoF must be integers');

domega = omega(2) - omega(1); % omega interval [rad/s]
t = tspan;                    % relocate time span for retardation calculation
nt = length(t);               % number of time steps in discretized retardation

% Initialize retardation kernel
k_t = zeros(nt, numDDoF);

% Kernel calculation
k_t = 2/pi * (cos(omega * t))' * K_omega * domega;

% Plot if enabled
if enablePlots
    load("DDoFname.mat");
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    figure;
    for iDDoF = 1:numDDoF
        if any(K_omega(:, iDDoF) ~= 0)
            subplot(numDoF, numDoF, iDDoF)
            plot(t, k_t(:, iDDoF),'LineWidth', 1.5);
            xlabel('Time (s)');
            ylabel('Retardation Function');
            title(DDoFname(iDDoF))
            xlim([0, max(t)]);  % Set x-axis limit to full time range
            grid on;
        end
    end
    sgtitle('Retardation Function in Time Domain')
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
end
fprintf('----------------------------------------------------------------\n')
fprintf('discrete freq domain kernal ==> discrete time-domain kernal\n')

end


