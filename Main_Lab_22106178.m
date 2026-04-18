close all; clear                                                                % To clear the screen
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
xlim([0 55]);
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
xlim([0 55]);
xlabel('Time(second)');                                    
ylabel('Amplitude');
title('Zoomed Signal after preprocessing');

%% 5 Postprocessing

[pks, lks] = findpeaks(final_signal, 'MinPeakDistance', 224,'MinPeakProminence',.00001); %finding R_peak
%% 6 Comparition to pan tompkins
[~,r_peaks,~]=pan_tompkin(final_signal,fs,0);   %finding peak using pantompkins method

%% 7 Displaying Result

figure;
subplot(2,1,1);
plot(tm, final_signal);                                                       % plotting processed signal vs tm
hold on
plot(tm(ann), final_signal(ann), 'k*');                                       % ground truth displayed with black *
plot(tm(lks), final_signal(lks), 'r*');                                       % detected peaks displayed with red *
plot(tm(r_peaks), final_signal(r_peaks), 'g*');                                 % pan tompkins peak displayed with green *
hold off

legend('Filtered Signal', 'Ground Truth (Doctors Annotation)', 'Detected R-peaks', 'Pan-Tompkin Methods');

xlabel('Time (s)');
ylabel('Amplitude');
title('QRS Detection Result');

%figure;
subplot(2,1,2);
plot(tm, final_signal);                                                       % plotting processed signal vs tm
hold on
plot(tm(ann), final_signal(ann), 'k*');                                       % ground truth displayed with black *
plot(tm(lks), final_signal(lks), 'r*');                                       % detected peaks displayed with red *
plot(tm(r_peaks), final_signal(r_peaks), 'g*');                                 % pan tompkins peak displayed with green *
hold off
xlim([0 30]);
legend('Filtered Signal', 'Ground Truth (Doctors Annotation)', 'Detected R-peaks', 'Pan-Tomkins');

xlabel('Time (s)');
ylabel('Amplitude');
title('QRS Detection Result Zoomed image');
%% 8. Calculating TP, FP, FN and TN (Window-based method)

matchTolerance_sec = 0.15;                       % 150 ms
matchTolerance_samples = round(matchTolerance_sec * fs);                   %Match each detected peak to the nearest true reference beat

matchedReference = false(length(ann),1);                                   %ann=true annotation
matchedDetected  = false(length(lks),1);                                   %lks=detected annotation
matchedReference2 = false(length(ann),1);                                   %ann=true annotation
matchedDetected2  = false(length(r_peaks),1);                                   %r_peaks=detected annotation by pan tompkins method
TP = 0;
TP2 = 0;
% To find TP TN FP and FN for detected peak
for i = 1:length(lks)
    
    diff = abs(ann - lks(i));
    [minDiff, idx] = min(diff);
    
    if minDiff <= matchTolerance_samples && ~matchedReference(idx)
        TP = TP + 1;                                                 %if detected anotation matches true annotation increase the count
        matchedReference(idx) = true;
        matchedDetected(i) = true;
    end
end


%FP = sum(~matchedDetected);
%FN = sum(~matchedReference);

FP=length(lks)-TP;                             %to detect false positive
FN=length(ann)-TP;                             %to detect false negative


windowSize_sec = 0.2;                         % 200 ms window
totalWindows = floor(tm(end) / windowSize_sec); %calculate totalWindows

TN = totalWindows - (TP + FP + FN);

% % To find TP TN FP and FN for detected peak using pan-tompkins method
for i = 1:length(r_peaks)
    
    diff = abs(ann - r_peaks(i));
    [minDiff2, idx2] = min(diff);
    
    if minDiff2 <= matchTolerance_samples && ~matchedReference2(idx2)
        TP2 = TP2 + 1;                                                 %if detected anotation matches true annotation increase the count
        matchedReference2(idx2) = true;
        matchedDetected2(i) = true;
    end
end


%FP = sum(~matchedDetected);
%FN = sum(~matchedReference);

FP2=length(r_peaks)-TP2;                             %to detect false positive
FN2=length(ann)-TP2;                             %to detect false negative


%windowSize_sec = 0.2;                         % 200 ms window
%totalWindows = floor(tm(end) / windowSize_sec); %calculate totalWindows

TN2 = totalWindows - (TP2 + FP2 + FN2);

%% 9. Calculating Sensitivity, Specificity, positive predictive value or the negative predictive value

Accuracy= ( TP + TN )/totalWindows;
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
PPV = TP / (TP + FP);
PNV = TN/ (TN + FN);

Accuracy2= ( TP2 + TN2 )/totalWindows;
Sensitivity2 = TP2 / (TP2 + FN2);
Specificity2 = TN2 / (TN2 + FP2);
PPV2 = TP2 / (TP2 + FP2);
PNV2 = TN2/ (TN2 + FN2);
%% 10. Displaying the results
fprintf('\n--- Performance and Comparision ---\n');
Method = {'Applied Method'; 'Pan-Tompkins Method'; 'Difference'};

TP = [TP; TP2; abs(TP-TP2)];
FP = [FP; FP2; abs(FP-FP2)];
FN = [FN; FN2; abs(FN-FN2)];
TN = [TN; TN2; abs(TN-TN2)];

Accuracy = [Accuracy; Accuracy2; abs(Accuracy-Accuracy2)];
Sensitivity = [Sensitivity; Sensitivity2; abs(Sensitivity-Sensitivity2)];
Specificity = [Specificity; Specificity2; abs(Specificity-Specificity2)];
PPV = [PPV; PPV2; abs(PPV-PPV2)];
NPV = [PNV; PNV2; abs(PNV-PNV2)];

ResultsTable = table(Method, TP, FP, FN, TN, ...
    Accuracy, Sensitivity, Specificity, PPV, NPV);

disp(ResultsTable);
%% 11 save workspace
save('Workspace/Workspace_22106178.mat');