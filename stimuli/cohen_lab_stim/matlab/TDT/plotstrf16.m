%
% function [] = plotstrf16(STRFData16,AudioChannel,MaxDelay,frange,Order)
%
%	FILE NAME   : PLOTSTRF16
%	DESCRIPTION : Computes Tunning Curve Online and Plots Results
%
%   STRFData16  : STRF 16 Channel Data Structure
%   AudioChannel: 1 or 2 (Default==1)
%   MaxDelay    : Maximum Delay for plotting (msec), Optional
%   frange      : Frequency Range = [f1 f2], Optional
%                 f1=Lower Frequency to plot (kHz)
%                 f2=Upper Frequency to plot (kHz)
%   Order       : Channel Order for Plotting
%
%RETURNED DATA
%   
%
function [] = plotstrf16(STRFData16,AudioChannel,MaxDelay,frange,Order)

%Input Arguments
if nargin<3
    MaxDelay=max(STRFData16(1).taxis)*1000;
end
if nargin<4
    frange=[min(STRFData16(1).faxis)/1000 max(STRFData16(1).faxis)/1000];
end
if nargin==5
    [STRFData16] = strfreorder16(STRFData16,Order);
end

%Time and Freq. Axis
taxis=STRFData16(1).taxis;
faxis=STRFData16(1).faxis;
f1=frange(1);
f2=frange(2);

%Plotting FTC Data
subplotorder=[1:2:16 2:2:16];
for chan=1:16
    subplot(8,2,subplotorder(chan))
    if AudioChannel==1
        pcolor(taxis*1000,log2(faxis/faxis(1)),STRFData16(chan).STRF1),shading flat,colormap jet
    else
        pcolor(taxis*1000,log2(faxis/faxis(1)),STRFData16(chan).STRF2),shading flat,colormap jet
    end
    axis([0 MaxDelay log2(f1*1000/faxis(1)) log2(f2*1000/faxis(1))])
end