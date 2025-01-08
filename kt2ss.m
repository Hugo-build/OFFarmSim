function [A,B,C,D] =  kt2ss(k_t,t,varargin)

p = inputParser;
addRequired(p,"k_t",@isnumeric);
addRequired(p,"t",@isnumeric);
addParameter(p,"order", [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
addParameter(p,"threshold", 0.99, @(x) isnumeric(x) && isscalar(x) && x > 0 && x < 1);
parse(p, k_t, t, varargin{:});

Nstate = p.Results.order;
threshold = p.Results.threshold;

dt = t(2) - t(1);  % Assuming uniform time step
[H, U, S, V, Edistr] = hankelSVD(k_t);

if isempty(Nstate)
    % Case: Number of states not specified, use threshold
    Nstate = zeros(1, size(k_t, 2));
    for i = 1:numel(U)
        cumEnergy = cumsum(Edistr{i});
        Nstate(i) = find(cumEnergy >= threshold, 1, 'first');
    end
    Nstate = max(Nstate);  % Use the maximum number of states across all components
else
    % Case: Number of states specified by user
    % Ensure Nstate doesn't exceed the size of the smallest S matrix
    max_possible_states = min(cellfun(@(x) size(x,1), S),[],"all");
    Nstate = min(Nstate, max_possible_states);
end


% Ur = cell(size(U));
% Sr = cell(size(U));
% Vr = cell(size(U));
% 
% % Truncate U, S, V based on Nstate
% for i = 1:numel(U)
%     Ur{i} = U{i}(:, 1:Nstate);
%     Sr{i} = S{i}(1:Nstate, 1:Nstate);
%     Vr{i} = V{i}(:, 1:Nstate);
% 
% end


% Compute state-space realization
A = cell(size(U)); 
B = cell(size(U));
C = cell(size(U));
D = cell(size(U));


for i = 1:numel(U) 
    if k_t(:,i)~= 0
        [Ar,Br,Cr,Dr] = retardation2ss(k_t(:,i), dt, Nstate);
        A{i} = Ar ; B{i} = Br ;
        C{i} = Cr ; D{i} = Dr ;
    end
end

% Compute A, B, C, D matrices
% for i = 1:numel(U)  
%     if all(Sr{i} == 0)
%         Ar = zeros(Nstate,Nstate);
%         Br = zeros(Nstate,1);
%         Cr = zeros(1,Nstate);
%         Dr = zeros(size(Cr,1), size(Br,2));
%     else
%         Sr_sqrt = sqrt(Sr{i});
%         Sr_sqrt_inv = sqrt(inv(Sr{i}));
%         Ar = Sr_sqrt_inv * Ur{i}(1:end-1,:)'* Ur{i}(2:end,:) * Sr_sqrt_inv;%/dt
%         Br = Sr_sqrt * Vr{i}(1,:)';     %/sqrt(dt)
%         Cr = Ur{i}(1,:) * Sr_sqrt;      %*sqrt(dt)
%         Dr = k_t(1,i);
%     end
%     A{i} = Ar ; B{i} = Br ;
%     C{i} = Cr ; D{i} = Dr ;
% end
% 
% % If only one component, return matrices instead of cell arrays
% if isscalar(A)
%     A = A{1};
%     B = B{1};
%     C = C{1};
%     D = D{1};
% end


end
