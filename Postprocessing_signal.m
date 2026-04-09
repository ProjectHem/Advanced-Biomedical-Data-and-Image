%% 1 Postprocessing

%To find the R peak
load('IntermediateSignals/D_BandPass_filter_result.mat');
[pks, lks] = findpeaks(final_signal, 'MinPeakDistance', 224);
figure;
%subplot(2,1,1);
plot(tm, final_signal);                                                       % signa
hold on
plot(tm(ann), final_signal(ann), 'k*');                                       % ground truth displayed with black *
plot(tm(lks), final_signal(lks), 'r*');                                       % detected peaks displayed with red *
hold off

legend('Filtered Signal', 'Ground Truth (Downloaded Annotation)', 'Detected R-peaks');

xlabel('Time (s)');
ylabel('Amplitude');
title('QRS Detection Result');

figure;
%subplot(2,1,2);
plot(tm, final_signal);                                                       % signal
hold on
plot(tm(ann), final_signal(ann), 'k*');                                       % ground truth displayed with black *
plot(tm(lks), final_signal(lks), 'r*');                                       % detected peaks displayed with red *
hold off
xlim([0 30]);
legend('Filtered Signal', 'Ground Truth (Downloaded Annotation)', 'Detected R-peaks');

xlabel('Time (s)');
ylabel('Amplitude');
title('QRS Detection Result Zoomed image');

%% 2. Calculating TP, FP, FN and TN (Window-based method)

matchTolerance_sec = 0.15;                       % 150 ms
matchTolerance_samples = round(matchTolerance_sec * fs);

matchedReference = false(length(ann),1);             %ann=true annotation
matchedDetected  = false(length(lks),1);             %lks=detected annotation

TP = 0;

% For Matching
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

%% 3. Calculating Sensitivity, Specificity, positive predictive value or the negative predictive value

Accuracy= ( TP + TN )/totalWindows;
Sensitivity = TP / (TP + FN);
Specificity = TN / (TN + FP);
PPV = TP / (TP + FP);
PNV = TN/ (TN + FN);
%% 4. Displaying the results
fprintf('\n--- Performance ---\n');
fprintf('TP = %d\n', TP);
fprintf('FP = %d\n', FP);
fprintf('FN = %d\n', FN);
fprintf('TN = %d\n', TN);
fprintf('Accuracy = %.4f\n', Accuracy);
fprintf('Sensitivity = %.4f\n', Sensitivity);
fprintf('Specificity = %.4f\n', Specificity);
fprintf('positive predictive value = %.4f\n', PPV);
fprintf('negative predictive value = %.4f\n', PNV);