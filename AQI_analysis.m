%% ThingSpeak Configuration

channelID = YOUR_CHANNEL_ID; % Channel ID (found on ThingSpeak)
readAPIKey = 'CHANNEL_READ_API_KEY';
nobs = 50; % number of observations

% Read data from ThingSpeak channel
% Field 1: PM 2.5 values
% Field 2: PM 10 values
data = thingSpeakRead(channelID, 'Fields', [1, 2], 'NumPoints', nobs, 'ReadKey', readAPIKey, OutputFormat='timetable');

disp(data)

timestamps = data.Timestamps;

% Extract the pm2.5 and pm10 data
pm25 = data.pm25;
pm10 = data.pm10;

%% Exploring Air data using PM 2.5 and PM 10 measurements

figure('Name', 'Dust Measurements')

plot(timestamps, pm25, '-o', 'LineWidth', 1.5); 
hold on;
plot(timestamps, pm10, '-s', 'LineWidth', 1.5);
grid on;

xlabel('Sample number');
ylabel('Concentration (µg/m³)');
title('PM2.5 and PM10 over time');
legend('PM2.5','PM10');

%%
% Smooth with centered moving average (window 3)
smooth1 = movmean(pm25, 3);
smooth2 = movmean(pm10, 3);

figure('Name', 'Smoothed Air Data');

plot(timestamps, pm25, 'o--'); hold on;
plot(timestamps, smooth1, 'LineWidth', 2);
plot(timestamps, pm10, 's--');
plot(timestamps, smooth2, 'LineWidth', 2);
grid on;

legend('PM2.5 raw','PM2.5 smoothed','PM10 raw','PM10 smoothed');
title('Smoothed vs Raw Data');

%% The relationship between the two pollutants. 

corr_value = corrcoef(pm25, pm10);
disp(corr_value) % correlation matrix

% Let's see whether PM2.5 and PM10 rise together

figure('Name', 'pm25 vs pm10');

scatter(pm25, pm10, 60, 'filled');
grid on;

xlabel('PM 2.5');
ylabel('PM 10');
title('PM 2.5 vs PM 10');

%% The Correlation between pm25 and pm10 values

% fitting a simple regression model
mdl = fitlm(pm25, pm10);

figure('Name', 'Linear Regression');

plot(mdl);

% Get all line/scatter handles and increase their size
ax = gca;
allLines = findobj(ax, 'Type', 'Line');
allScatter = findobj(ax, 'Type', 'Scatter');

% Increase fitted line and confidence bound line widths
for i = 1:length(allLines)
    allLines(i).LineWidth = 2;
end

% Increase scatter marker size
for i = 1:length(allScatter)
    allScatter(i).SizeData = 40;  % default is ~36
    allScatter(i).MarkerFaceAlpha = 0.7;
end

disp('Regression Results:');
disp("R-squared: " + mdl.Rsquared.Ordinary)
disp("Intercept: " + mdl.Coefficients.Estimate(1))
disp("Slope: " + mdl.Coefficients.Estimate(2))


xlabel('PM2.5 (ug/m3)');
ylabel('PM10 (ug/m3)');
title(sprintf('PM2.5 vs PM10 Regression (R²= %.3f)', ...
    mdl.Rsquared.Ordinary));
grid on;
%%
% Spikes detection (pollution events)
% Useful for identifying:
% Cooking, Smoking, Opening windows and Traffic passing by anomalies.

mu = mean(pm25);
threshold25 = mu + 2*std(pm25);
spikes25 = pm25 > threshold25;

fprintf('\nAnomalies detected: %d readings\n', sum(spikes25));

figure('Name', 'Anomaly Detection');

plot(timestamps, pm25, 'b-', 'LineWidth', 1); 
hold on;

scatter(timestamps(spikes25), pm25(spikes25), ...
    80, 'r', 'filled', 'DisplayName', 'Anomaly');
yline(threshold25, 'r--', ...
    sprintf('Threshold (%.1f)', threshold25), 'LineWidth', 1.5);
yline(mu, 'g--', sprintf('Mean (%.1f)', mu), 'LineWidth', 1.2);
xlabel('Time');
ylabel('PM2.5 (ug/m3)');

title('Parma PM2.5 — Anomaly Detection');
legend('PM2.5', 'Anomalies', 'Location', 'northwest');

grid on;


%% World Health Organization (WHO) Limits and guidelines

% WHO Limits:
% PM2.5: 5 µg/m³ annual, 15 µg/m³ daily
% PM10: 15 µg/m³ annual, 45 µg/m³ daily

% WHO limits
WHO_PM25_annual = 5;
WHO_PM25_daily  = 15;

WHO_PM10_annual = 15;
WHO_PM10_daily  = 45;

figure('Name', 'WHO Limits')

% --- PM2.5 subplot ---
subplot(2,1,1);
plot(timestamps, pm25, '-o', 'LineWidth', 1.5); hold on;
yline(WHO_PM25_annual, 'g--', 'WHO PM2.5 Annual (5 µg/m³)', 'LineWidth', 1.2);
yline(WHO_PM25_daily,  'r--', 'WHO PM2.5 Daily (15 µg/m³)',  'LineWidth', 1.2);
grid on;

xlabel('Sample number');
ylabel('PM2.5 (µg/m³)');
title('PM2.5 vs WHO Air Quality Guidelines');
legend('Measured PM2.5');

% --- PM10 subplot ---
subplot(2,1,2);
plot(timestamps, pm10, '-s', 'LineWidth', 1.5); hold on;
yline(WHO_PM10_annual, 'g--', 'WHO PM10 Annual (15 µg/m³)', 'LineWidth', 1.2);
yline(WHO_PM10_daily,  'r--', 'WHO PM10 Daily (45 µg/m³)',  'LineWidth', 1.2);
grid on;

xlabel('Sample number');
ylabel('PM10 (µg/m³)');
title('PM10 vs WHO Air Quality Guidelines');
legend('Measured PM10');

%% ARIMA Forecasting for PM2.5

% Define forecast horizon
forecastSteps = 24;

% Fit ARIMA model
model = arima(2,1,2);
fitModel = estimate(model, pm25);

% Generate Forecast
[forecastValues, forecastMSE] = forecast( ...
    fitModel, ...
    forecastSteps, ...
    'Y0', pm25);

% Confidence intervals
upperBound = forecastValues + 1.96*sqrt(forecastMSE);
lowerBound = forecastValues - 1.96*sqrt(forecastMSE);

% Future time index
futureIndex = length(pm25)+1 : length(pm25)+forecastSteps;

% Plot forecast
figure('Name', 'ARIMA Forecast');

plot(pm25,'b', 'LineWidth',2)
hold on
plot(futureIndex, forecastValues,'r','LineWidth',2)
plot(futureIndex, upperBound,'k--')
plot(futureIndex, lowerBound,'k--')

legend('Actual','Forecast','Upper','Lower')
title('ARIMA Forecast')
grid on