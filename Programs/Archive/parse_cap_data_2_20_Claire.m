clear; close all;

files = dir('CAP_DAT/1_17/*.csv');      % structure with all the info of files in directory
filenames = {files.name}';              % extracts file names
filenames = filenames(1:end);           % removes '.' and '..'

combinedData = zeros(0);

% Iterate through filenames
for i = 1:length(filenames)

    % Select file name from filenames
    filename = string(filenames(i)); % CSV file name
    filename = strcat("CAP_DAT/1_17/", filename);
    file = readtable(filename);

    % Read file as text to locate header rows
    fileText = fileread(filename);
    lines = strsplit(fileText, '\n');
    
    % Find all occurrences of the rows containing 'FREQ', 'Z[ohm]' and 'PHASE[deg]'
    freqRows = find(contains(lines, 'FREQ'));
    dataRows = find(contains(lines, 'Z[ohm]'));

    dataEntries = zeros(length(dataRows), 7);
    
    % Find data
    for j = 1:length(dataRows)
        
        % Parse impedence/phase angle data
        dataRow = dataRows(j) + 1; 
        data_str = lines(dataRow);
        data_str = erase(data_str, '"');
        data_values = split(data_str, ',');
        
        Z = str2double(data_values{1});
        Phase = str2double(data_values{2});

        % Caroline's obnoxious parsing to extract frequency
        freqRow = freqRows(j);
        freqRow = erase(lines(freqRow), '"');
        freqData = split(freqRow, ',');
        
        Freq = str2double(freqData{2});

        % Calculate real and imaginary parts
        real_part = Z * cosd(Phase);
        imag_part = Z * abs(sind(Phase));

        % Calculate capacitance and ESR 
        
        Cap = 1/(2 * pi * Freq * imag_part);
        ESR = real_part;

        dataEntries(j, :) = [Freq, Z, Phase, real_part, imag_part, Cap, ESR];
                % Append extracted data
    end

    combinedData = [combinedData; dataEntries];

end

tableData = array2table(combinedData, 'VariableNames', {'Frequency (Hz)', ...
            'Impedance (Ohm)', 'PhaseAngle (Deg)', 'Real Part', 'Imaginary Part', ...
            'Calculated Capacitance (F)', 'Calculated ESR (Ohm)'});

filename_write = '/Tables/02_17_25_Hioki_combinedData.xlsx'; % Adjust as preferred
writetable(tableData, [pwd filename_write]);

