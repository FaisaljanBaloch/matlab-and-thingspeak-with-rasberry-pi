%% ThingSpeak Configuration

channelID = YOUR_CHANNEL_ID; % Channel ID (found on ThingSpeak)
readAPIKey = 'CHANNEL_READ_API_KEY';
nobs = 10; % number of observations

% Read data from ThingSpeak channel
% Field 1: PM 2.5, Field 2: PM 10 values 
data = thingSpeakRead(channelID, 'Fields', [1, 2], 'NumPoints', nobs, 'ReadKey', readAPIKey);

disp(data)

%%
% Create a time vector (1 second between samples)
t = 1:nobs;

% Extract the two signals
signal1 = data(:,1);
signal2 = data(:,2);

% Plot both signals
figure;
plot(t, signal1, '-o', 'LineWidth', 1.5); hold on;
plot(t, signal2, '-s', 'LineWidth', 1.5);
grid on;

xlabel('Observation number');
ylabel('Measured value');
title('Collected Sensor Data');
legend('Signal 1','Signal 2');

%%
figure;
scatter(signal1, signal2, 60, 'filled');
grid on;

xlabel('Signal 1');
ylabel('Signal 2');
title('Signal 1 vs Signal 2');


%%
stats.mean1 = mean(signal1);
stats.mean2 = mean(signal2);

stats.std1 = std(signal1);
stats.std2 = std(signal2);

stats.min1 = min(signal1);
stats.min2 = min(signal2);

stats.max1 = max(signal1);
stats.max2 = max(signal2);

stats


%%

smooth1 = movmean(signal1, 3);
smooth2 = movmean(signal2, 3);

figure;
plot(t, signal1, 'o--'); hold on;
plot(t, smooth1, 'LineWidth', 2);
plot(t, signal2, 's--');
plot(t, smooth2, 'LineWidth', 2);
grid on;

legend('Signal 1 raw','Signal 1 smoothed','Signal 2 raw','Signal 2 smoothed');
title('Smoothed vs Raw Data');


%%

corr_value = corrcoef(signal1, signal2);
corr_value


%%
%1. Time‑series plot (PM2.5 & PM10 over time)
%This is the most fundamental air‑quality visualization.

%What it tells you:
%Pollution trends

%Spikes (cooking, traffic, dust)

%Sensor stability

t = 1:nobs;
pm25 = data(:,1);
pm10 = data(:,2);

figure;
plot(t, pm25, '-o', 'LineWidth', 1.5); hold on;
plot(t, pm10, '-s', 'LineWidth', 1.5);
grid on;

xlabel('Sample number');
ylabel('Concentration (µg/m³)');
title('PM2.5 and PM10 over time');
legend('PM2.5','PM10');


%%
%2. PM2.5 vs PM10 scatter plot
%Shows the relationship between the two pollutants.

%What it tells you:
%Whether PM2.5 and PM10 rise together

%Whether pollution is fine‑particle dominated (common indoors)

%Whether dust dominates (common outdoors)
figure;
scatter(pm25, pm10, 60, 'filled');
grid on;

xlabel('PM2.5 (µg/m³)');
ylabel('PM10 (µg/m³)');
title('Correlation between PM2.5 and PM10');

%%
%Spike detection (pollution events)
%Useful for identifying:

%Cooking

%Smoking

%Opening windows

%Traffic passing by

threshold25 = mean(pm25) + 2*std(pm25);
spikes25 = pm25 > threshold25;
disp(spikes25)

%%
%Histogram (distribution of pollution levels)
%Shows how often certain pollution levels occur.


figure;
subplot(1,2,1);
histogram(pm25);
title('PM2.5 distribution');
xlabel('µg/m³');

subplot(1,2,2);
histogram(pm10);
title('PM10 distribution');
xlabel('µg/m³');


%%
%9. Compare your data to WHO limits
%WHO guidelines:

%PM2.5: 5 µg/m³ annual, 15 µg/m³ daily

%PM10: 15 µg/m³ annual, 45 µg/m³ daily

%I can generate a plot with WHO limits overlaid.


% Extract signals
pm25 = data(:,1);
pm10 = data(:,2);
t = 1:length(pm25);

% WHO limits
WHO_PM25_annual = 5;
WHO_PM25_daily  = 15;

WHO_PM10_annual = 15;
WHO_PM10_daily  = 45;

figure;

% --- PM2.5 subplot ---
subplot(2,1,1);
plot(t, pm25, '-o', 'LineWidth', 1.5); hold on;
yline(WHO_PM25_annual, 'g--', 'WHO PM2.5 Annual (5 µg/m³)', 'LineWidth', 1.2);
yline(WHO_PM25_daily,  'r--', 'WHO PM2.5 Daily (15 µg/m³)',  'LineWidth', 1.2);
grid on;

xlabel('Sample number');
ylabel('PM2.5 (µg/m³)');
title('PM2.5 vs WHO Air Quality Guidelines');
legend('Measured PM2.5');

% --- PM10 subplot ---
subplot(2,1,2);
plot(t, pm10, '-s', 'LineWidth', 1.5); hold on;
yline(WHO_PM10_annual, 'g--', 'WHO PM10 Annual (15 µg/m³)', 'LineWidth', 1.2);
yline(WHO_PM10_daily,  'r--', 'WHO PM10 Daily (45 µg/m³)',  'LineWidth', 1.2);
grid on;

xlabel('Sample number');
ylabel('PM10 (µg/m³)');
title('PM10 vs WHO Air Quality Guidelines');
legend('Measured PM10');

