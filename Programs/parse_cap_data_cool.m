clear; close all;

dates = ["2_17" "2_25" "2_28" "3_6"];
hours = [0 66.6 112.35 161.4];
num_caps = 40;

test_freq = 10000;

cap_vals = zeros(length(dates), num_caps) + NaN;
esr_vals = zeros(length(dates), num_caps) + NaN;

for k = 1:length(dates)
    list = ls("CAP_DAT/" + dates(k));
    
    
    filepath = "CAP_DAT/" + dates(k) + "/"; %path to CSVs
    combinedData = strings(0);
    
    for i = 3:length(list)
    
        filename = append(filepath, list(i, :)); %CSV file name
        file = readtable(filename);
        
        % Read file as text to locate header rows
        fileText = fileread(filename);
        lines = strsplit(fileText, '\n');
        
        % Find all occurrences of the header row containing 'Z[ohm]' and 'PHASE[deg]'
        headerRows = find(contains(lines, 'Z[ohm]'));
        frequencyRows = find(contains(lines, 'FREQ'));
        
        for j = 1:length(headerRows)
            dataRow = headerRows(j) + 1; % Data starts immediately after header
    
            str = lines(dataRow);
        
            % Remove double quotes
            str = erase(str, '"');
            
            % Split into two parts
            values = split(str, ',');
            
            % Convert to double
            Z = str2double(values{1});
            Phase = str2double(values{2});
    
            %obnoxious parsing to extract frequency
            freqRow = frequencyRows(j);
            freqRow = erase(lines(freqRow), '"');
            freqData = split(freqRow, ',');
            Freq = str2double(freqData{2});
    
            Res = cosd(Phase) * Z;
            Cap = -1/(sind(Phase) * Z* 2 * pi * Freq);

            if Freq == test_freq
                cap_vals(k, i-2) = Cap;
            end

            if Freq == test_freq
                esr_vals(k, i-2) = Res;
            end
            
        end
    end
end

figure(1);
plot(hours, cap_vals(:,:)/(10^-9));
xlabel("time aged (hours)");
ylabel("Capacitance (nF)")
title("capacitance (nF) vs time aged at " + test_freq + "Hz");

figure(2);
plot(hours, esr_vals(:,:));
xlabel("time aged (hours)");
ylabel("ESR (ohms)")
title("ESR (ohms) vs time aged at " + test_freq + "Hz");
