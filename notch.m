%% notch filter
function[signal_out]=notch(fc,fs,Qf,signl, titles)
wo = fc/(fs/2);
% Design notch filter
[bNO, aNO] = designNotchPeakIIR( ...
    'CenterFrequency', wo, ...
    'QualityFactor', Qf, ...
    'Response', 'notch');
signal_out = filtfilt(bNO, aNO, signl);              %applying filter
figure;
[hNO, wNO] = freqz(bNO, aNO, 100);
plot(wNO/pi*(fs/2), mag2db(abs(hNO)))
ylabel('Mag (dB)')
xlabel('Frequency (Hz)')
title(titles)
end