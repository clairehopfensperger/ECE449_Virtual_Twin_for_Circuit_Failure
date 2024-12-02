%--------------------------------------
% This script calculates the capacitor
% value in a simple RC lowpass filter
% based on the following input
% measured values:
%   - Input voltage (DC offset, AC amp,
%       AC angle)
%   - Output voltage (DC offset, AC amp,
%       AC phase shift from input voltage)
%   - Resistance (Ohm)
%   - Corner Frequency (Hz)
%
% Output: Capacitance, graph of input
%   and output voltages
%--------------------------------------
clear; close all;


%--------------------------------------
% Input measured values
%--------------------------------------
R = 160.4;  % Ohms
f = 10E3;   % Hz

Vin_DC_offset = 4;                      % V
Vin_pp_mag = 6.4;                       % V, peak to peak voltage

Vout_DC_offset = 4;                     % V
Vout_pp_mag = 4.48;                     % V, peak-to-peak voltage

time_diff_manual = 11.4E-6;             % s
phase_offset_auto = 40.04;              % Degrees, phase offset of Vout compared to Vin


%--------------------------------------
% Calculations for other input values
%--------------------------------------
% Input voltage values
Vin_mag = Vin_pp_mag / 2;               % V, amplitude
Vin_angle = 0;                          % Degrees
Vin_rad = Vin_angle * pi / 180;         % Rads

% Phase offset from Vin -> Vout (Vout phase - Vin phase)
phase_offset_manual = time_diff_manual / (1/f) * 360;
phase_offset_manual_rad = phase_offset_manual * pi / 180;
phase_offset_auto_rad = phase_offset_auto * pi / 180;

% Output voltage values
Vout_mag = Vout_pp_mag / 2;             % V, amplitude
Vout_rad = Vin_rad + phase_offset_auto_rad;  % Rads

w = 2 * pi * f;
j = sqrt(-1);


%--------------------------------------
% Creating Vin and Vout Phasors
%--------------------------------------
t = linspace(0, 3E-1, 1E3);

Vin = fPhasor(Vin_mag * cos(Vin_rad) + j * Vin_mag * sin(Vin_rad));

Vout = fPhasor(Vout_mag * cos(Vout_rad) + j * Vout_mag * sin(Vout_rad));


%--------------------------------------
% Plotting Vin and Vout
%--------------------------------------
figure();
hold on;
grid on;
title('Vin and Vout');
xlabel('Time (ms)');
ylabel('Voltage (V)');
ylim([0 (Vin_DC_offset + Vin_mag + 1)]);
plot(t, Vin_DC_offset + Vin.Mag * sin(w * t - Vin.Rad));
plot(t, Vout_DC_offset + Vout.Mag * sin(w * t - Vout.Rad));
legend('Vin', 'Vout');



%--------------------------------------
% Calculate Capacitance
%--------------------------------------
% Not 100% sure if this is supposed to be phase_offset_rad or Vout_rad lol!
phi_manual = -phase_offset_manual_rad;
phi_auto = -phase_offset_auto_rad;

%phi = -atan(w * R * C);
C_manual = tan(-phi_manual) / (w * R)
C_auto = tan(-phi_auto) / (w * R)


%--------------------------------------
% Calc ideal and measured transfer
% functions
%--------------------------------------
%H_ideal = 1 / ((j * w * R * (100E-9)) + 1);
%Vout_Vin_actual = Vout.P / Vin.P;


%--------------------------------------
%% Phasor function from Dr. Scott in 301
function Phasor = fPhasor(P)
    Phasor.P      = P;
    Phasor.Mag    = abs(P);
    Phasor.Rad    = angle(P);
    Phasor.Ang    = angle(P)*180/pi;
    Phasor.Re     = real(P);
    Phasor.Im     = imag(P);
end
