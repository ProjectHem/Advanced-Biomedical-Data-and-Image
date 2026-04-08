%% Band Pass Filter
function[output_signal]=bandpass(fc, high, low, order, input)
output_signal=input;
if low~=0
    Nofo=low;
    wNO=Nofo/(fc/2);
    bNO=fir1(order,wNO);                             %default lowpass
    output_signal=filtfilt(bNO,1,output_signal);
end

if high~=0
    Nofo=high;
    wNO=Nofo/(fc/2);
    bNO=fir1(order,wNO);                             %default highpass
    output_signal=filtfilt(bNO,1,output_signal);
end
end
