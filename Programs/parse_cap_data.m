clear; close all;

dates = ["2_17", "2_25", "2_28", "3_6", "3_13", "3_20", "3_31", "4_3", "4_10"];
hours = [0, 66.6, 112.35, 161.4, 211.2, 261.36, 311.06, 358.24, 406.51];
num_caps = 40;

test_freq = 10000;

cap_vals = zeros(length(dates), num_caps) + NaN;
esr_vals = zeros(length(dates), num_caps) + NaN;

for k = 1:length(dates(1, :))
    list = ls("CAP_DAT/" + dates(k));
    
    
    filepath = "CAP_DAT/" + dates(k) + "/"; %path to CSVs
    combinedData = strings(0);
    
    for i = 3:length(list(:, 1))
    
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

row = 1;
textPlacementHours = zeros(1, num_caps);
for i = 1: 1: num_caps/5
    row = row + 1;
    for j = 1: 1: 5
        
        textPlacementHours(num_caps-i*5+j) = hours(row);
    end
end

cap_vals_graph = zeros(length(dates), num_caps) + NaN;
esr_vals_graph = zeros(length(dates), num_caps) + NaN;

cap_vals_end = zeros(1, num_caps);
esr_vals_end = zeros(1, num_caps);

for i = 1: 1: num_caps
    last_hour_index = length(hours) - floor((i-1)/5);
    for j = 1: 1: last_hour_index
        cap_vals_graph(j, i) = cap_vals(j, i);
        esr_vals_graph(j, i) = esr_vals(j, i);

        if j == last_hour_index
            cap_vals_end(i) = cap_vals(j, i);
            esr_vals_end(i) = esr_vals(j, i);
        end
    end
end
figure(1);
plot(hours, cap_vals_graph(:,:)/(10^-9));
xlabel("Time Aged (hours)", 'FontSize', 26);
ylabel("Capacitance (nF)", 'FontSize', 26)
title("Capacitance (nF) vs Time Aged at " + test_freq + "Hz", 'FontSize', 36);

cap = 1:1:40;
str = sprintf('cap %d\t',cap);
strs = strsplit(str,'\t');
%fancy nonsense to make the fontsize of cap 2 and 25 bigger.
text(textPlacementHours(1),cap_vals_end(1)/(10^-9),strs(1));
text(textPlacementHours(2),cap_vals_end(2)/(10^-9),strs(2), 'FontSize', 18, 'FontWeight','bold');
text(textPlacementHours(3:24),cap_vals_end(3:24)/(10^-9),strs(3:24));
text(textPlacementHours(26:num_caps),cap_vals_end(26:num_caps)/(10^-9),strs(26:num_caps));
text(textPlacementHours(25),cap_vals_end(25)/(10^-9),strs(25), 'FontSize', 18, 'FontWeight','bold');
yregion(95, 80, 'FaceColor', 'g'); 
yregion(80, 75, 'FaceColor', 'r'); 

figure(2);
plot(hours, esr_vals_graph(:,:));
xlabel("Time Aged (hours)", 'FontSize', 26);
ylabel("ESR (ohms)", 'FontSize', 26)
title("ESR (ohms) vs Time Aged at " + test_freq + "Hz", 'FontSize', 36);
%fancy nonsense to make the fontsize of cap 2 and 25 bigger.
text(textPlacementHours(1),esr_vals_end(1),strs(1));
text(textPlacementHours(2),esr_vals_end(2),strs(2), 'FontSize', 18, 'FontWeight','bold');
text(textPlacementHours(3:24),esr_vals_end(3:24),strs(3:24));
text(textPlacementHours(26:num_caps),esr_vals_end(26:num_caps),strs(26:num_caps));
text(textPlacementHours(25),esr_vals_end(25),strs(25), 'FontSize', 18, 'FontWeight','bold');
yregion(18, 10, 'FaceColor', 'g'); 
yregion(24, 18, 'FaceColor', 'r'); 

