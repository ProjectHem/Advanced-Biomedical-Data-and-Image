%% 1. Loadig the ECG signal

[signal, fs, tm] = rdsamp('Data/107',1);                  % read dataset 107 channel 1
ann=rdann('Data/107','atr');                              % read the annotationann = rdann('107','atr');
figure;
subplot(2,1,1);
plot(tm,signal);                                        % Visualize the signal;
xlabel('Time(second)');                                    
ylabel('Amplitude');
title('MITDB ECG.Patient 107');
%save('IntermediateSignals/A_Patient_107','signal','fs','tm','ann'); % saves file inside IntermediateSignals folder
%[SNR_Raw]=SNR_from_spectrum(signal,fs);            % to find the signal to noise ratio of original signal
%fprintf('Raw ECG SNR: %0.2f dB\n', SNR_Raw);             % to display the signal to noise ratio

subplot(2,1,2);
plot(tm,signal);                                        % Visualize the signal;
xlim([0 30]);
xlabel('Time(second)');                                    
ylabel('Amplitude');
title('MITDB ECG.Patient 107 Zoomed Image');
save('IntermediateSignals/A_Patient_107','signal','fs','tm','ann'); % saves file inside IntermediateSignals folder
[SNR_Raw]=SNR_from_spectrum(signal,fs);            % to find the signal to noise ratio of original signal
fprintf('Raw ECG SNR: %0.2f dB\n', SNR_Raw);             % to display the signal to noise ratio

%% 2 Frequency Spectrum Analysis (ECG)

Myfft(signal, fs, 'ECG Double-Sided Amplitude Spectrum', 'ECG Single-Sided Amplitude Spectrum');
%% 3 Preprossing with filters

%% 3.1 Removeing powerline noises at frequency 60Hz, 120Hz and 180Hz using IIR Notch Filter
Qf=10;                                                % let Quality factor=10
Processed_signal_60 = notch(60,fs,Qf,signal, 'Frequency Response of the notch filter at 60 Hz');          % remove frequency 60 Hz using IIR Notch Filter
Myfft(Processed_signal_60,fs, 'Double sided Amplitude Spectrum after 60 Hz notch filter','Single sided Amplitude Spectrum after 60 Hz notch filter', 58,62);

Processed_signal_120 = notch(120,fs,Qf,Processed_signal_60, 'Frequency Response of the notch filter at 120 Hz');          % remove frequency 60 Hz using IIR Notch Filter
Myfft(Processed_signal_120,fs, 'Double sided Amplitude Spectrum after 60 Hz and 120 HZ notch filter','Single sided Amplitude Spectrum after 60 Hz and 120 Hz notch filter',118,122);

Processed_signal_180 = notch(180,fs,Qf,Processed_signal_120, 'Frequency Response of the notch filter at 180 Hz');          % remove frequency 60 Hz using IIR Notch Filter
Myfft(Processed_signal_180,fs, 'Double sided Amplitude Spectrum after 60Hz, 120Hz and 180HZ notch filter','Single sided Amplitude Spectrum after 60Hz, 120Hz and 180 Hz notch filter',178,182);

save('IntermediateSignals/B_Notch_filter_result','Processed_signal_180','fs','tm','ann');

[SNR_180]=SNR_from_spectrum(Processed_signal_180,fs);    % to display the signal to noise ratio after applying Notch Filter
fprintf(' After Removing powerline noises ECG SNR: %0.2f dB\n', SNR_180);             % to display the signal to noise ratio
%% 3.2 Removing DC Signal and Baseline wandeing using high passfilter
lamda=0.98;
DC_remove_signal = Remove_the_DC(Processed_signal_180, lamda);         
Myfft(DC_remove_signal,fs, 'Double sided Amplitude Spectrum after removing DC noise','Single sided Amplitude Spectrum after removing DC noise');

save('IntermediateSignals/C_Removing_DC_signal','DC_remove_signal','fs','tm','ann');

[SNR_DC_remove]=SNR_from_spectrum(DC_remove_signal,fs);    % to display the signal to noise ratio after removing DC signal
fprintf(' After Removing DC signal ECG SNR: %0.2f dB\n', SNR_DC_remove);             % to display the signal to noise ratio
%% 3.3 Applying Band Pass Filter at HPF(5Hz) and LPF (15Hz)
order=10;              %assiging filter order as 10
final_signal=bandpass(5, 1,0, order, DC_remove_signal);                              %using as highpass filter (5Hz)
final_signal=bandpass(15, 0,1, order, final_signal);                                 %using as lowpass filter (15Hz)
Myfft(final_signal,fs, 'Double sided Amplitude Spectrum after applying Band Pass Filter HPF(5Hz) and LPF(15Hz)', 'Single sided Amplitude Spectrum after applying band pass filter HPF(5Hz) and LPF (15Hz)');

save('IntermediateSignals/D_BandPass_filter_result','final_signal','fs','tm','ann');

[SNR_BPF]=SNR_from_spectrum(final_signal,fs);                                        % to display the signal to noise ratio after applying Bandpass Filter
fprintf(' After applying bandpass filter ECG SNR: %0.2f dB\n', SNR_BPF);             % to display the signal to noise ratio

%% 4 Displaying the Processed Signal 

figure;
subplot(2,1,1);
plot(tm,final_signal);
xlabel('Time(second)');                                    
ylabel('Amplitude');
title('Signal after preprocessing');
subplot(2,1,2);
plot(tm,final_signal);
xlim([0 30]);
xlabel('Time(second)');                                    
ylabel('Amplitude');
title('Zoomed Signal after preprocessing');