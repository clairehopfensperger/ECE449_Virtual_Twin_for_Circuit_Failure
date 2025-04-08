% +------------------------------------------------------+
% |             Phase Difference Measurement             |
% |              with MATLAB Implementation              | 
% |                                                      |
% | Author: M.Sc. Eng. Hristo Zhivomirov        12/01/14 | 
% +------------------------------------------------------+
% 
% function: PhDiff = phdiffmeasure(x, y, fs, method)
%
% Input:
% x - first signal in the time domain
% y - second signal in the time domain
% fs - sampling frequency, Hz
% method - method to be used for the estimation of the phase difference
%          'dft' - phase difference measurement via spectral analysis
%          'corr' - phase difference measurement via correlation analysis
% 
% Output:
% PhDiff - phase difference Y -> X (Y w.r.t. X), rad or
%          time difference Y -> X (Y w.r.t. X), s
%
% Note: the two input signals could be with different lenght and/or
% different sampling frequency. In the last case, one should use the 'dft'
% method and should set the fs to an arbitrary positive value (e.g., 1000).

function PhDiff = phdiffmeasure(x, y, fs, method)

% input validation
validateattributes(x, {'single', 'double'}, ...
                      {'vector', 'nonnan', 'nonempty', 'real', 'finite'}, ...
                      '', 'x', 1)
validateattributes(y, {'single', 'double'}, ...
                      {'vector', 'nonnan', 'nonempty', 'real', 'finite'}, ...
                      '', 'y', 2)
validateattributes(fs, {'double'}, ...
                       {'scalar', 'nonnan', 'nonempty', 'positive'}, ...
                       '', 'fs', 3)

% represent the signals as column-vectors
x = x(:);
y = y(:);

% remove the DC component of the signals
x = x - mean(x);
y = y - mean(y);

% apply the appropriate method
switch method
    case 'corr'
        PhDiff = phdiffviacorr(x, y, fs);
    case 'dft'
        PhDiff = phdiffviadft(x, y);
    otherwise
        % throw an error message
        error('Choose a valid method for phase difference estimation (see the help)!')
end      

% phdiffviacorr fuction
function PhDiff = phdiffviacorr(x, y, fs)

% time lag measurement
[Cx, lags] = xcorr(x, y, 'none');
tau = lags/fs;
[~, maxind] = max(Cx);

% time difference estimation
PhDiff = -tau(maxind);

end

% phdiffviadft fuction
function PhDiff = phdiffviadft(x, y)

% windows generation
xwin = hanning(length(x), 'periodic');
ywin = hanning(length(y), 'periodic');

% perform fft on the signals
X = fft(x.*xwin); 
Y = fft(y.*ywin);

% fundamental frequency detection
[~, indx] = max(abs(X));
[~, indy] = max(abs(Y));

% phase difference estimation
PhDiff = angle(Y(indy)) - angle(X(indx));

% restrict the phase difference in the range [-pi, pi]
PhDiff = mod(PhDiff + pi, 2*pi) - pi;

end

end