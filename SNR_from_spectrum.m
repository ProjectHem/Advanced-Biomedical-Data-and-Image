function y = SNR_from_spectrum(x,fs)
X = fft(x);     % Fast Fourier transform
X = 2*abs(X)/length(X); % Convert complex numbers to real numbers
% Calculate signal-to-noise ratio (SNR) from the spectrum:
P = X.^2;       % Calculate the power of the spectrum
df = fs/length(x);  % Frequency interval
f=0:df:fs-df;   % Frequency vector for frequency axis
% Calculate the power of the noise:
Pnoise = sum(P(1:round(0.67/df)))/round(0.67/df) + ...  % Noise from DC to 0.67 Hz
        sum(P(1+round(150/df):end))/(round((fs/2)/df)-(1+round(150/df))) ...    % Noise from 150 Hz to fs/2
        + P(round(60/df)) ...   % Noise at 60 Hz
        + P(round(120/df));     % Noise at 120 Hz
% Calculate the power of the signal of interest:
Psignal = sum(P(1+round(0.67/df):round(149/df)));   % Signal from 0.67 Hz to 149 Hz
y = 10*log10(Psignal/Pnoise);   % SNR in dB
end