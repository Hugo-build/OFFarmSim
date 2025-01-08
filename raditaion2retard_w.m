function [K_omega_real1, omega1] = raditaion2retard_w(A_omega, B_omega, omega, varargin)
% -------------------------------------------------------------------------
% Calculates the retardation function in frequency domain
%
% Inputs:
%   A_omega: Added mass matrix in frequency domain
%   B_omega: Damping matrix in frequency domain
%   omega: Frequency vector
%   Name-Value Pairs:
%     'EnablePlots': Flag to enable plotting (default: false)
%     'NumInterpolationPoints': Number of interpolation points (default: 1000)
%
% Outputs:
%   K_omega_real1: Interpolated retardation function
%   omega1: Interpolated frequency vector
%   mse: Mean squared error of the interpolation
%
% Use raditaion2retard_w('help') to display available name-value pairs
% -------------------------------------------------------------------------

% Set up input parser
p = inputParser;
addRequired(p, 'A_omega', @isnumeric);
addRequired(p, 'B_omega', @isnumeric);
addRequired(p, 'omega', @isnumeric);
addParameter(p, 'EnablePlots', false, @islogical);
addParameter(p, 'NumInterpPoints', 1000, ...
             @(x) isnumeric(x) && isscalar(x) && x > 0);

% Parse inputs
parse(p, A_omega, B_omega, omega, varargin{:});

% Extract parsed values
enablePlots = p.Results.EnablePlots;
numInterpPoints = p.Results.NumInterpPoints;

% Find Degrees of Freedom
numDDoF = size(B_omega, 2); % [nDoF x nDoF]
numDoF = sqrt(numDDoF);     % [nDoF]

% Check if numDDoF and numDoF are integers
assert(mod(numDDoF, 1) == 0 && mod(numDoF, 1) == 0, 'numDDoF and numDoF must be integers');

% Check real part of retardation in frequency domain
K_omega_real = B_omega - B_omega(end,:);

% Interpolation
omega1 = linspace(omega(1), omega(end), numInterpPoints)';
K_omega_real1 = interp1(omega, K_omega_real, omega1, 'linear', 'extrap');

% Calculate MSE of interpolation
% mse = mean((interp1(omega1, K_omega_real1, omega, 'linear', 'extrap') - K_omega_real).^2, 'all');
% fprintf('Mean Squared Error of Interpolation: %e\n', mse);

% Plot if enabled
if enablePlots
    load("DDoFname.mat");
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    figure
    for iDDoF = 1:numDDoF
        if any(K_omega_real(1:end-1,iDDoF) ~= 0)
            subplot(numDoF, numDoF, iDDoF)
            plot(omega, K_omega_real(:,iDDoF), 'LineWidth', 1.2, 'Color', 'k'); hold on
            plot(omega1, K_omega_real1(:,iDDoF), 'LineWidth', 1.2, 'Color', 'r', 'LineStyle', ':')
            xlabel('\omega (Hz)')
            ylabel('K(\omega)')
            title(DDoFname(iDDoF))
        end
    end
    sgtitle('Retardation Function in Frequency Domain')
    %^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
end

fprintf('----------------------------------------------------------------\n')
fprintf('discrete A & B in omega ==> discrete freq-domain kernal\n')

end