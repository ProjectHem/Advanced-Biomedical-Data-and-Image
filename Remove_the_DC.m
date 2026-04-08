%% High pass filter
function[signal_out]=Remove_the_DC(input_signal, value)
b=[1 -1];
a=[1 -value];
signal_out=filtfilt(b,a,input_signal);
end