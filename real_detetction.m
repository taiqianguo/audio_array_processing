
% Load the audio data and sample rate
load handel.mat;

% Parameters
audioData = y;
sampleRate = Fs;
duration = length(audioData) / sampleRate;
x = linspace(-10, 10, 500);
y = linspace(-10, 10, 500);
[X, Y] = meshgrid(x, y);
t = linspace(0, duration, length(audioData));

% Define positions to monitor and calculate indices robustly
pos1 = [2, 2]; % Position 1
pos2 = [2, 2.1]; % Position 2
[~, idx1_x] = min(abs(x - pos1(1))); % Closest x index to Position 1
[~, idx1_y] = min(abs(y - pos1(2))); % Closest y index to Position 1
[~, idx2_x] = min(abs(x - pos2(1))); % Closest x index to Position 2
[~, idx2_y] = min(abs(y - pos2(2))); % Closest y index to Position 2

data1 = zeros(size(t));
data2 = zeros(size(t));

% Prepare for plotting
figure;
subplot(1,2,1);
hSurf = surf(X, Y, zeros(size(X)), 'EdgeColor', 'none'); % For the 2D wave plot
title('2D Wave Propagation');
xlabel('X (meters)');
ylabel('Y (meters)');
zlabel('Amplitude');
shading interp;
zlim([-0.1 0.1]);

% Plot for time response at positions
subplot(1,2,2);
hold on;
plot1 = plot(t, zeros(size(t)), 'LineWidth', 2); % For position 1
plot2 = plot(t, zeros(size(t)), 'y', 'LineWidth', 2); % For position 2
title('Received Signal Over Time');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend(['Position (' num2str(pos1) ')'], ['Position (' num2str(pos2) ')']);
ylim([-0.03 0.03]);
xlim([0, 0.03]);
hold off;

r = sqrt(X.^2 + Y.^2);
% Animation loop
for k = 1:length(t)
    delay = r / 343;
    % Generate the wave at each point considering delay
    %theta = 2 * pi * sampleRate * (t(k) - delay);
    %Z = (audioData(k) * sin(theta)) ./ (1 + r / 2);
    %delay = distances / speed_of_sound;
    valid_indices = t(k) >= delay;  % Only consider points where the sound has reached
    theta = 2 * pi * sampleRate * ((t(k) - delay) .* valid_indices);
    Z = zeros(size(X));
    if k > 1
        amplitude_factor = audioData(max(1, k - round(delay * sampleRate))) .* valid_indices;
    else
        amplitude_factor = zeros(size(X));
    end
    Z(valid_indices) = amplitude_factor(valid_indices) .* sin(theta(valid_indices)) ./ (1 + r(valid_indices) / 2);


    % Update the 2D wave plot
    set(hSurf, 'ZData', Z);
    drawnow;
    
    % Collect data for each position
    data1(k) = Z(idx1_x, idx1_y);
    data2(k) = Z(idx2_x, idx2_y);
    [b, a] = butter(4, 100/(Fs/2), 'low');
    y1 = filter(b, a, data1);
    y2 = filter(b, a, data2);
    set(plot1, 'XData', t(1:300), 'YData', y1(1:300));
    set(plot2, 'XData', t(1:300), 'YData', y2(1:300));


    % Cross-correlate the two signals
    [correlation, lags] = xcorr(data2(1:k), data1(1:k));

    % Find the index of the maximum correlation
    [~, idx] = max(abs(correlation));
    timeDelay = lags(idx) / sampleRate;

    % Calculate the difference in distance
    speedOfSound = 343; % Speed of sound in air in m/s
    distanceDifference = speedOfSound * timeDelay;

    % Display the results
    fprintf('Time Delay: %f seconds\n', timeDelay);
    fprintf('Distance Difference: %f meters\n', distanceDifference);
    fprintf('arrival angle:%f degree\n' ,rad2deg(asin(distanceDifference/sqrt((pos1(1)-pos2(1))^2 + (pos1(2)-pos2(2))^2 ))));

end





