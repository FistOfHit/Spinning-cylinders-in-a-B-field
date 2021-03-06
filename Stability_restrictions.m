% Script to find relationship between h (space step size) and k (time step size)
% to ensure stability of Finite difference methods used.
%
% Works by starting with a value of h from a range of values needing testing, and 
% starts at a very small, almost certainly stable (for any reasonable value of h)
% value of k. The solution is then calculated for these values of h and k and 
% tested for stability by seeing if any value over all space has grown above 2
% in magnitude (the reason for this is clear on analysing the PDE's). If the 
% solution had begin to diverge clearly, end this iteration and store the highest 
% stable value of k for this value of h. If not, then continue increasing the 
% value of k and retest.
%
% Script produces an raw data plot and a log-log plot and performs Linear 
% regression by least square method, to find (assumed) power law relationship
% between h and k.


% Define array of spatial step sizes
num_space_steps = linspace(50, 200, 30);

% Maximum timestep size array
max_k = zeros(length(num_space_steps), 1);

% Find maximum time step size for each value of h
for i = 1:length(num_space_steps)
    
    % Setting up steps in r
    N = ceil(num_space_steps(i));
    stable = 1;
    
    k = 0.001;
    
    % Keep testing larger and larger values of k until stability is lost
    while (stable)
        
        % Find solution at 10^4 timesteps
        psi = Plot_fieldlines(N, 10^4, k, 0.01, 0);
        
        % Check if solution has diverged outside of bounds
        if (any(any(abs(psi) > 2)))
            max_k(i) = k;
            stable = 0;
        end
            
        % Iterate k to larger value
        k = k + 0.001;
        
    end
    
end

% Plot raw data 
figure;
plot(num_space_steps, max_k, '+');
title('Plot of maximum time step size against space step size for stability');
xlabel('Space step size');
ylabel('Maxmimum time step size');

% Log-Log plot and linear regression
log_y_data = log(max_k);
log_x_data = [ones(length(num_space_steps), 1), transpose(log(num_space_steps))];
grad_incept = log_x_data\log_y_data;
disp(['gradient = ', num2str(grad_incept(2)), ', y-intercept = ', num2str(grad_incept(1))]);

% Plotting Log-Log data
figure;
plot(log_x_data(:, 2), log_y_data, '+');
hold on;
plot(log_x_data(:, 2), log_x_data(:, 2)*grad_incept(2) + grad_incept(1));
hold off;
title('Log-Log plot of maximum time step size for varying space step sizes');
xlabel('Log(space step size)');
ylabel('Log(maximum time step size)');
legend('Log-Log data', ['LR fitted line - gradient = ', num2str(grad_incept(2))]);

disp(grad_incept)






