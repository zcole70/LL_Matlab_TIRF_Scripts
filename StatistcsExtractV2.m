% MATLAB Script to Select, Process, and Save a Pruned Data Table

% Prompt user to select the .txt file
[fileName, filePath] = uigetfile('*.txt', 'Select the .txt file');
if isequal(fileName, 0)
    disp('User canceled the file selection.');
    return;
end

% Construct the full file path
fullFilePath = fullfile(filePath, fileName);

% Read the .txt file into a table
opts = detectImportOptions(fullFilePath, 'FileType', 'text');
opts.DataLines = [2 Inf]; % Start reading from the second line to exclude headers
opts.VariableNamesLine = 1; % Use the first line for variable names
dataTable = readtable(fullFilePath, opts);

% Display the full table in MATLAB
disp('Full table successfully converted:');
disp(dataTable);

% Prune the table to keep only the specified columns
columnsToKeep = {'d', 'ncross', 'donorlife', 'bg'};
if all(ismember(columnsToKeep, dataTable.Properties.VariableNames))
    prunedTable = dataTable(:, columnsToKeep);
    disp('Pruned table:');
    disp(prunedTable);
else
    error('One or more specified columns are not present in the table.');
end

% Prompt user to choose the save location and name for the .mat file
[saveFileName, saveFilePath] = uiputfile('*.mat', 'Save As');
if isequal(saveFileName, 0)
    disp('User canceled the save operation.');
    return;
end

% Save the pruned table as a MAT file
save(fullfile(saveFilePath, saveFileName), 'prunedTable');
disp(['Pruned table saved as MAT file: ', fullfile(saveFilePath, saveFileName)]);
