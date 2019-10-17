%
%function
%[TetrodeDataAligned]=tetrodewaveformalign(TetrodeData,AlignWindow,method)
%
%   FILE NAME   : TETRODE WAVEFORM ALIGN 
%   DESCRIPTION : Align the waveforms of detected spikes from
%                 tetrode recording
%
%   TetrodeData : Input Tetrode Data Structure
%                 .Snip - Snips for detected spikes
%                 .MD   - Mahalanobis Distance
%                 .Spet - Spike event times (sample number)
%                 .Fs   - Sampling rate (Hz)
%                 .C    - Tetrode covariance matrix
%                 .ParamName   -Parameters 
%                 .ParamValue  -Value of Parameters
%   AlignWindow : Maximum Time window allowed for waveform alignment (msec)
%                 (Default == 0.2 msec)
%   Method      : Alignment method. 1= align based on maximum correlation
%                 point with the mean; 2= align based on maximum summed energy; 3= align
%                 on channel that has biggest negative peak (Default ==1)
%  
% 
%RETURNED PARAMETERS
%   TetrodeDataAlgined : Output Aligned Tetrode Data Structure
%                 .Snip - Aligned Snips for detected spikes
%                 .MD   - Mahalanobis Distance
%                 .Spet - Aligned Spike event times (sample number)
%                 .Fs   - Sampling rate (Hz)
%                 .C    - Tetrode covariance matrix
%                 .ParamName   -Parameters 
%                 .ParamValue  -Value of Parameters
%                 .shift -Amount of shifts for each individual spike in
%                         sample number
%                
%                
% (C) C.Chen July 2008, Last Edit Spet 2009
%
function [TetrodeDataAligned]=tetrodewaveformalign(TetrodeData,AlignWindow,method)

if nargin<3
    method=1;
end
if nargin<2
    AlignWindow=.2;
end
TetrodeDataAligned=TetrodeData;
MaxShift=ceil(AlignWindow/1000*TetrodeData.Fs);
waveform=TetrodeData.Snip;
N=size(waveform,1); % # of spikes
M=size(waveform,3); % # of samples per spike
waveforma=zeros(N,4,M-2*MaxShift);
%MD=zeros(N,M-2*MaxShift);
shift=zeros(1,N);
a=squeeze(mean(waveform,1));
%a=[a(1,:) a(2,:) a(3,:) a(4,:)];
%plot(a')
for n=1:N
    b=squeeze((waveform(n,:,:)));
    %plot(b')
    %b=[b(1,:) b(2,:) b(3,:) b(4,:)];
    switch method     
        case 1
            xab=xcorr2(a,b);  
            [x,i]=max(max(xab));
            s=M-i;
        case 2
            [x,i]=max(sum(b.^2));   
            s=ceil(M/2)-i;
        case 3
            [x,i]=min(min(b));
            s=ceil(M/2)-i;
    end                    

    if abs(s)<MaxShift
        waveforma(n,:,:)=waveform(n,:,[MaxShift+1:M-MaxShift]+s); 
        shift(n)=s;
    else    
        waveforma(n,:,:)=waveform(n,:,[MaxShift+1:M-MaxShift]);
    end    
    %Z=(squeeze(waveforma(n,:,:)).*(inv(TetrodeData.C)* squeeze(waveforma(n,:,:))));
    %MD(n,:)=sqrt(sum(Z,1));
end

TetrodeDataAligned.Snip=waveforma;
TetrodeDataAligned.Spet=TetrodeData.Spet+shift;
TetrodeDataAligned.shift=shift;
%TetrodeDataAligned.MD=MD;
TetrodeDataAligned.AlignWindow=AlignWindow;

% %
% id=find(diff(TetrodeData.Spet)==0);
% i=setdiff(length(TetrodeData.Spet),id);
% TetrodeDataAligned.Spet=TetrodeDataAligned.Spet(i);
% TetrodeDataAligned.Snip=TetrodeDataAligned.Snip(i,:,:);
% TetrodeDataAligned.shift=TetrodeDataAligned.shift(i);