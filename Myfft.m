%% fucntion to display single sided and double sided spectrum

function[] = Myfft(sig,fs,titl, titl2, x1, x2)
N = length(sig);
ECG_fft = fft(sig);


f = (fs/N)*(0:N-1); % Frequency axis

% Magnitude spectrum (normalized)
mag = abs(ECG_fft)/N;

% 2.1 Two-sided spectrum
figure;
subplot(2,1,1);
plot(f, mag,'LineWidth',1);

xlabel('Frequency (Hz)');
ylabel('Magnitude');
title(titl);

if nargin >= 5 && ~isempty(x1) && ~isempty(x2)
    xlim([x1 x2]);                            % to show filter acticities
end

% 2.2 Single-sided spectrum 
f1 = f(1:floor(N/2)+1);
mag1 = mag(1:floor(N/2)+1);
mag1(2:end-1) = 2*mag1(2:end-1);

subplot(2,1,2);
plot(f1, mag1,'LineWidth',1);


xlabel('Frequency (Hz)');
ylabel('Magnitude');
title(titl2);
if nargin >= 5 && ~isempty(x1) && ~isempty(x2)
    xlim([x1 x2]);                          % to show filter activities
end

end