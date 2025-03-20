% MATLAB Script to Create Combined Bar Graphs and Compute Statistics for Columns in prunedTable

% Load the prunedTable (if not already loaded)
if ~exist('prunedTable', 'var')
    [matFileName, matFilePath] = uigetfile('*.mat', 'Select the MAT file containing prunedTable');
    if isequal(matFileName, 0)
        disp('User canceled the file selection.');
        return;
    end
    load(fullfile(matFilePath, matFileName), 'prunedTable');
end

% Ensure prunedTable exists
if ~exist('prunedTable', 'var')
    error('prunedTable not found in the workspace or the selected MAT file.');
end

% Define the original and new variable names
originalNames = {'d', 'ncross', 'donorlife', 'bg', 'snr'};
newNames = {'Donor Intensity', 'Donor Blinks', 'Donor Lifetime', 'Background', 'Signal to Noise Ratio'};

% Check if all required columns exist in the table
missingColumns = setdiff(originalNames, prunedTable.Properties.VariableNames);
if ~isempty(missingColumns)
    error('Missing columns in prunedTable: %s', strjoin(missingColumns, ', '));
end

% Rename variables in the table
for i = 1:numel(originalNames)
    prunedTable.Properties.VariableNames{originalNames{i}} = newNames{i};
end

% Ask the user for the timescale value
timescale = input('What timescale value does each frame represent in seconds? ', 's');
timescale = str2double(timescale);

% Validate user input
if isnan(timescale) || timescale <= 0
    error('Invalid input. Please enter a positive numeric value.');
end

% Compute the frame rate
frameRate = 1 / timescale;

% Adjust only the Donor Lifetime values
prunedTable.("Donor Lifetime") = prunedTable.("Donor Lifetime") / frameRate;

% Initialize arrays to store statistics
numColumns = numel(newNames);
averages = zeros(numColumns, 1);
stdDevs = zeros(numColumns, 1);

% Create a single figure for all bar graphs
figure;
tiledlayout(2, 3); % Arrange subplots in a 2x3 grid (adjust as needed)

% Iterate over each specified column in prunedTable
numBins = 30; % Number of bins for the histogram
for i = 1:numColumns
    % Extract column data
    columnData = prunedTable.(newNames{i});
    
    % Ignore NaN values
    columnData = columnData(~isnan(columnData));
    
    % Calculate histogram data
    [counts, edges] = histcounts(columnData, numBins, 'Normalization', 'probability');
    
    % Compute bin centers
    binCenters = edges(1:end-1) + diff(edges) / 2;
    
    % Store X and Y values in the workspace
    X = binCenters;
    Y = counts;
    assignin('base', [strrep(newNames{i}, ' ', '_'), '_X'], X);
    assignin('base', [strrep(newNames{i}, ' ', '_'), '_Y'], Y);
    
    % Calculate statistics
    averages(i) = mean(columnData);
    stdDevs(i) = std(columnData);
    
    % Create a subplot for the current column
    nexttile;
    bar(X, Y, 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'none');
    title(['Normalized Frequency: ', newNames{i}]);
    xlabel(newNames{i});
    ylabel('Normalized Frequency');
    
    % Add text annotations for average and standard deviation
    avgText = sprintf('Avg: %.2f', averages(i));
    stdText = sprintf('Std Dev: %.2f', stdDevs(i));
    annotationText = {avgText, stdText};
    text('Units', 'normalized', 'Position', [0.7, 0.9], ...
         'String', annotationText, 'FontSize', 10, 'Color', 'black', ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
         'BackgroundColor', 'white', 'EdgeColor', 'black');
end

% Create a table with the statistics
StatsTable = table(newNames', averages, stdDevs, ...
    'VariableNames', {'ColumnName', 'Average', 'StandardDeviation'});

% Assign the statistics table to the workspace
assignin('base', 'StatsTable', StatsTable);
assignin('base', 'prunedTable', prunedTable); % Save prunedTable with new names and adjusted Donor Lifetime

% Display the statistics table
disp('Statistics Table:');
disp(StatsTable);

disp('Donor Lifetime values adjusted based on user input.');
disp('Combined bar graphs generated, X and Y values stored, and statistics table created.');
