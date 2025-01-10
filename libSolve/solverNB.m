function [t,x] = solverNB(feq,tSpan, x0)

    switch nargin
        case 3
            gamma = 0;
            beta = 0;
            fprintf('gamma == %f && beta == %f', gamma, beta)
        case 5
    end

    numSteps = ceil((tEnd - tStart) / dt);
    time = zeros(numSteps, 1);
    state = zeros(2 * ndof, numSteps); % Combined displacements and velocities
    
    % Initial value
    state(:, 1) = x0;
    
    % Newmark Beta integration
    for i = 1:numSteps
        time(i) = tStart + (i - 1) * dt;
        
        % Calculate acceleration
        a = feq(time(i), state(:, i));
        
        % Update state
        if i > 1
            state(:, i) = state(:, i - 1) + dt * v + ...
                (0.5 - beta) * dt^2 * a;
        end
        
        % Calculate new acceleration based on updated state
        a = feq(time(i), state(:, i));
        
        % Update velocity
        v = v + dt * ((1 - gamma) * a + gamma * feq(time(i) + dt, state(:, i)));
        
        % Store results
        state(1:ndof, i) = state(1:ndof, i) + dt * v; % Update displacements
        state((ndof + 1):end, i) = v; % Update velocities
    end
    
    % Extract displacements and velocities for analysis if needed
    displacements = state(1:ndof, :);
    velocities = state((ndof + 1):end, :);
    
    x = state;
    t = tStart:dt:tEnd;


end