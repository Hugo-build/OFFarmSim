function varargout = hankelSVD(k_t, varargin)
% -------------------------------------------------------------------------
% Analyze Hankel matrix of retardation kernel
%
% Inputs:
%   k_t - retardation kernel time series
%   cal_Edistr - calculate energy distribution
%   plot_Edistr - plot energy distribution
%
% Outputs:
%   U, S, V - SVD components of Hankel matrix
%   Edistr - cumulative energy distribution of singular values
% -------------------------------------------------------------------------

% Parse input arguments
p = inputParser;
addRequired(p, 'k_t');
addOptional(p, 'plotFlag', false, @(x) islogical(x) || isnumeric(x));
parse(p, k_t, varargin{:});
plot_Edistr = p.Results.plotFlag;



dimK_t = numel(size(k_t));

switch dimK_t
    case 2
        numDDoF = size(k_t, 2);
        numDoF  = sqrt(numDDoF);
    case 3
        numDoF  = size(k_t, 3);
        numDDoF = numDoF^2;
        k_t = reshape(k_t,[[],numDDoF]);
    otherwise
        error('dimension of k_t should be either [nt, nDDoF], or [nt, nDoF, nDoF]')
end

maxStates = floor(size(k_t, 1) / 2);  % Maximum possible states

H = cell(numDoF, numDoF);
U = cell(numDoF, numDoF);
S = cell(numDoF, numDoF);
V = cell(numDoF, numDoF);
Edistr = cell(numDDoF, 1);
Ecum   = cell(numDDoF, 1);

for iDDoF = 1:numDDoF
    k_ij = k_t(:,iDDoF);
    % Construct Hankel matrix
    H{iDDoF} = hankel(k_ij(1:end-maxStates), k_ij(end-maxStates:end));
    % Singular Value Decomposition
    [U{iDDoF}, S{iDDoF}, V{iDDoF}] = svd(H{iDDoF}); 
end

% Calculate energy distribution
cal_Edistr = (nargout > 4) || plot_Edistr;
if cal_Edistr
    for iDDoF = 1:numDDoF
        % Calculate energy distribution
        singularValues = diag(S{iDDoF});
        Etot = sum(singularValues.^2);
        Edistr{iDDoF} = singularValues.^2 / Etot;
        % Add cumulative energy line
        Ecum{iDDoF} = cumsum(Edistr{iDDoF});
    end
    
    if plot_Edistr
        load("ddofFoot.mat")
        figure;
        for iDDoF = 1:numDDoF
            if any(k_t(:,iDDoF))  % Plot only if k_t is not all zeros
                subplot(numDoF, numDoF, iDDoF);
                
                yyaxis left
                hold on
                % Plot bar graph
                bar(Edistr{iDDoF}, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'none');
                
                title(['K_{' char(ddofFoot(iDDoF)) '}']);
                xlabel('i');
                ylabel('E_i/E_{tot}');
                grid on;
                ylim([0, 1]);
                
                % Set xlim to exclude near-zero values
                threshold = 1e-2;  % Adjust this value as needed
                significantIndices = find(Edistr{iDDoF} > threshold);
                if ~isempty(significantIndices)
                    xlim([0.5, max(significantIndices) + 1]);
                else
                    xlim([0.5, length(Edistr{iDDoF})]);
                end
                
                
                yyaxis right
                hold on
                plot(Ecum{iDDoF}, 'LineWidth', 1.5);
                ylabel('Cumulative Energy');
                ylim([0, 1]);

                set(gca,"fontsize",16)
                set(gca,"fontname","times")
            end
        end
        sgtitle('Energy distribution of retardation kernel');
    end
end

% Prepare outputs based on nargout
outputs = {H, U, S, V, Edistr};
varargout = outputs(1:nargout);

end
