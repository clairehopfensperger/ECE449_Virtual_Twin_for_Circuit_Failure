clear; close all;

filename = 'CAP_DAT/1_17/250217180740.csv'; % CSV file name
file = readtable(filename);

% Read file as text to locate header rows
fileText = fileread(filename);
lines = strsplit(fileText, '\n');

% Find all occurrences of the header row containing 'Z[ohm]' and 'PHASE[deg]'
headerRows = find(contains(lines, 'Z[ohm]'));

dataEntries = zeros(length(headerRows), 2);

for i = 1:length(headerRows)
    dataRow = headerRows(i) + 1; % Data starts immediately after header
    
    str = lines(dataRow);

    % Remove double quotes
    str = erase(str, '"');
    
    % Split into two parts
    values = split(str, ',');
    
    % Convert to double
    Z = str2double(values{1});
    Phase = str2double(values{2});

    dataEntries(i, :) = [Z, Phase]; % Append extracted data
end

tableData = array2table(dataEntries, 'VariableNames', {'Impedance', 'PhaseAngle'});

disp('Extracted Data Table:');
disp(tableData);