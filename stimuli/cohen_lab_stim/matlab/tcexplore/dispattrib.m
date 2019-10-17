%function dispattrib(dummy)
%This function dumps the attribute matrix to the screen with a legend.
%Note: the matrix is transposed and the format is short for display purposes.

function dispattrib(dummy)

ui_handles = get(figure(1), 'userdata');
save_button = ui_handles(22);
attributes = get(save_button, 'userdata');

disp('1=File Index, 2=CF-in kHz, 3=Threshold w/external attn,')
disp('4=external Atten')
disp('6=Q10, 7=A10, 8=B10, 9=Bandwidth10, 10=Asym10')
disp('11=Q20, 12=A20, 13=B20, 14=Bandwidth20, 15=Asym20')
disp('16=Q30, 17=A30, 18=B30, 19=Bandwidth30, 20=Asym30')
disp('21=Q40, 22=A40, 23=B40, 24=Bandwidth40, 25=Asym40')
disp('26=Latency, 27=MaxRate, 28=MaxRate@CF, 29=Amp@maxrateCF')
disp('30=Rate-Level Slope1 - % of TransPoint response @CF per dB')
disp('31=Rate-Level Slope2, 32=NonMonotonic(=1), 33=Amp@TransPoint')

numbers=[1: 1: size(attributes, 2)]'; 
attributes(:,1)=attributes(:,1) / 10000;
format short
disp([numbers attributes'])
