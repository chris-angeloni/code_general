%
%function [TetrodeData]=tetrodespikedetect(Tetrode,C,Thresh,T,fl,fh,US,DeadTime,AlignWindow,Disp)
%
%   FILE NAME   : TETRODE SPIKE DETECT
%   DESCRIPTION : Detects action potentials across 4 channel tetrode. Uses
%                 mormalized energy , or Mahalanobis Distance to detect spikes:                 
%                 Mahalanobis Distance (MD)= X(C^-1)X', where X is tetrode
%                 signal vector and and C is the tetrode covariance matrix
%   Tetrode     : .mat file that contains 4 channel of continous waveforms
%                 in a tetrode (4 x number of samples)
%   C           : Covariance matrix (4 x 4) if available
%   Thresh      : Threshold for spike detecting; Default=5 
%	T           : Spike Snippet window size (msec) (Default==2 msec)
%	fl          : Lower cutoff frequency for bandpass filter; Default=300
%	fh          : Higher cutoff frequency for bandpass filter; Default=5000
%   US          : Upsampling factor 
%   DeadTime    : Minimum time between adjecent spikes (msec) - Secondary 
%                 spikes within this time window are not detected
%                 (Default==0.5 msec)
%   AlignWindow : Timme window for shifting spikes during waveform
%                 alignment(Default==0.2 msec)    
%   Disp        : Display output results (Default=='n')
% 
%RETURNED PARAMETERS
%
%	TetrodeData : Output Tetrode Data Structure
%                 .Snip - Snips for detected spikes
%                 .MD   - Mahalanobis Distance (normalized energy)
%                 .Spet - Spike event times (sample number), Note that this
%                         is defined as the where the normalized energy 
%                         peaks. This is also the Mid point of the Snip
%                         waveform.
%                 .Fs   - Sampling rate (Hz)
%                 .C    - Tetrode covariance matrix
%                 .ParamName   -Parameters 
%                 .ParamValue  -Value of Parameters
%                
%                
% (C) C.Chen & M. Escabi, July 2008       Last Edit (Chen, Sept 2009; MAE, April 2016)
%
function [TetrodeData]=tetrodespikedetect(Tetrode,C,Thresh,T,fl,fh,US,DeadTime,AlignWindow,Disp)

%Input Arguments
if nargin<10
    Disp='y';
end
if nargin<9
    AlignWindow=0.2;
end
if nargin<8
    DeadTime=0.5;
end
if nargin<7
    US=4;
end
if nargin<6
   fh=5000;
end
if nargin<5
    fl=300;
end
if nargin<4
   T=2;
end
if nargin<3
   Thresh=[5 99];
end   
if nargin<2
    C=-9999;
end    

if length(Thresh)==1
    Thresh=[Thresh 99];
end    

%Truncate tetrode data to appropriate length and reshape
%[Tetrode]=truncatetetrode(Tetrode,Tetrode(1).Trig(end));
%Filter continous waveform
Fs=Tetrode(1).Fs;
H=bandpass(fl,fh,250,Fs,40,'n');
L=(length(H)-1)/2;
[N1,N2]=size(Tetrode(1).ContWave);
Y=zeros(4,N1*N2);
for i=1:4
    disp(['Filtering Channel ' int2str(i)])
	[N1,N2]=size(Tetrode(i).ContWave);
    ContWave=reshape(Tetrode(i).ContWave,1,N1*N2);
    X=conv(ContWave,H);
    N=length(X);
    X=X(L+1:N-L);
    Y(i,:)=X;
end 
clear Tetrode X


%Computig Covariance Matrix
if size(C,1)~=4
    %[C]=covblocked(Y',1,0,1024*512);       %Covariance
    [C]=covblocked(Y(:,1:Fs*60)',1,0,1024*512); % use the first minute of data to estimate covariance
end    
TetrodeData.C=C;
%Initialize Variables
Ns=ceil(T/2/1000*Fs);   %Total number of samples for spet = 2*Ns+1
L=Fs*US;                %Block Size - # samples
spet=[];
dt=DeadTime/1000;
count=1;
TetrodeData.Snip=zeros(500,4,2*Ns*US+1);
TetrodeData.MD=zeros(500,2*Ns*US+1);
    
%Spike Detection    


for k=1:ceil(length(Y)/L)
    clc
    disp(['Detecting Spikes ' int2str(round(k/ceil(length(Y)/L)*100)) ' % Done'])
    index=[];
    %Interpolating Waveform Blocks
    if length(Y)-(k-1)*L<L   %Checking for Last Segment
        Yt=Y(:,(k-1)*L+1-Ns:length(Y));  %Adding Ns at left extreme to assure that all spikes are detected
    elseif k==1
        Yt=[zeros(4,Ns) Y(:,1:L+1+Ns)]; %Add zeros at begining of first block
    else
        Yt=Y(:,(k-1)*L+1-Ns:min(k*L+1+Ns,length(Y))); %Adding Ns at extremes to assure that all spikes are detected
    end
    M=length(Yt);
    Ytemp=zeros(4,(M-1)*US);
    Yd=zeros(4,(M-1)*US);
    for l=1:4
        Ytemp(l,:)=interp1(1:M,Yt(l,:),1:1/US:M-1/US,'spline');
        Yd(l,:)=Ytemp(l,:)-mean(Ytemp(l,:));
    end
    clear Yt

    %Calculating Mahalanobis distance
    Z=(Yd.*(pinv(C)*Yd));   %MAE, April 2016 - previously inv()
    MD=sqrt(sum(Z,1));

    %Finding Samples that Exceed Threshold and Contain Peaks
    M=length(MD);
    NsU=Ns*US;      %Number of samples for upsampled snip = 2*NsU+1
    Mask=[zeros(1,NsU) ones(1,L*US) zeros(1,NsU)];    %Used to remove edge boundaries
    i=1+find(Mask(2:M-1) & MD(2:M-1)>Thresh(1) & MD(2:M-1)<Thresh(2) & (MD(2:M-1))>(MD(1:M-2)) & (MD(2:M-1))>(MD(3:M)) );
    if ~isempty(i)
        id=find(diff(i)/Fs/US>dt); % remove peaks within DeadTime
        index=[i(1) i(id+1)];
    end
    spet=[spet (k-1)*L*US+index-NsU];   %Corrects for offset due to NsU and + 1

    %Finding Spike & Feature Waveforms
    for l=1:length(index)
        if index(l)-NsU>0 && index(l)+NsU<size(Ytemp,2)+1
            TetrodeData.Snip(count,:,:)=Ytemp(:,index(l)-NsU:index(l)+NsU);
            TetrodeData.MD(count,:)=MD(index(l)-NsU:index(l)+NsU);
            count=count+1;
        end
    end
    TetrodeData.Spet=spet;

    %Dynamically Allocating Data Arrays
    TetrodeData.Snip(length(spet)+1:length(spet)+L/Fs/US*500,:,:)=zeros(L/Fs/US*500,4,2*Ns*US+1);
    TetrodeData.MD(length(spet)+1:length(spet)+L/Fs/US*500,:)=zeros(L/Fs/US*500,2*Ns*US+1);

    %Displaying Output Results
    if strcmp(Disp,'y')
        if k==1
            figure('Units','normalized','Position',[.1 .4 .8 .6])
        end
        subplot(511)
        Offset=(k-1)*M/Fs/US;
        plot(Offset+(1:length(MD))/Fs/US,MD)
        Max=max(MD);
        hold on
        plot(Offset + index/Fs/US,0.8*Max*ones(size(index)),'r+')
        axis([Offset Offset+M/Fs/US -Max Max])
        hold off

        for i=1:4
            subplot(5,1,i+1)
            Max=max(max(abs(Ytemp(i,:))));
            %Max=max(max(abs(Z(i,:))));
            plot(Offset+(1:length(Ytemp(i,:)))/Fs/US,Ytemp(i,:))
            %plot(Offset+(1:length(Z(i,:)))/Fs/US,Z(i,:));
            hold on
            plot(Offset+index/Fs/US,0.8*Max*ones(size(index)),'r+') 
            axis([Offset Offset+M/Fs/US -Max Max])
            hold off
            if i==4
                xlabel('Time (sec)')
            end
        end
        pause(0);
    end
end

%Truncating Data to Appropriate Size
TetrodeData.Fs=Fs*US;
TetrodeData.Snip=TetrodeData.Snip(1:length(TetrodeData.Spet),:,:);
TetrodeData.MD=TetrodeData.MD(1:length(TetrodeData.Spet),:);

%Align waveforms
[TetrodeData]=tetrodewaveformalign(TetrodeData,AlignWindow);

%Parameters
TetrodeData.ParamName='Thresh,T,fl,fh,US,DeadTime';
TetrodeData.ParamValue=[Thresh T fl fh US DeadTime];