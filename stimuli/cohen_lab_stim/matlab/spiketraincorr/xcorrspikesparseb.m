%
%function [R,Rb]=xcorrspikesparseb(spet1,spet2,Fs,Fsd,MaxTau,B,T,Zero,Mean,Disp)
%
%   FILE NAME   : XCORR SPIKE SPARSE B
%   DESCRIPTION : X-Correlation Function of Spike Train performed in blocks
%                 for bootstraping. Uses a fast algorithm that only 
%                 considers coincident spikes. This routine is useful for 
%                 sparse spike trains (<1 spike/bin) that are sampled at 
%                 high sampling rates (e.g., Fsd>1000 Hz). The algorigthm 
%                 is a modified version of XCORRSPIKESPARSE. It is similar 
%                 to XCORRSPIKEFAST but uses less memory and is ~100% 
%                 faster. Compared to XCORRSPIKE it is roughly 30 times
%                 faster (e.g., 10 min recording using 12kHz sampling
%                 rate, 0.6 sec versus 16.8 sec).
%
%   spet1,spet2	: Input Spike Event Times
%   Fs          : Samping Rate of SPET
%   Fsd         : Sampling Rate for R(T)
%   MaxTau      : X-Correlation Temporal Lag (msec)
%   B           : Block size (seconds)
%   T           : Experiment Duration (sec)
%   Zero        : Correct the Zeroth Bin when computing
%                 autocorrelation: spet1==spet2
%                 Default: 'y'
%   Mean        : Remove Mean Value
%                 Default: 'n'
%   Disp        : Display : 'y' or 'n'
%                 Default : 'y'
%
%RETURNED VALUES
%
%   R           : Crosscorrelation function
%   Rb          : Blocked crosscorrelation function. Data is analyized in
%                 blocks of B seconds. These samples can be used to
%                 bootstrap the data across blocks. Note that R=mean(Rb).
%
% (C) Monty A. Escabi, Aug 2009 (Edit Oct 2009)
%
function [R,Rb]=xcorrspikesparseb(spet1,spet2,Fs,Fsd,MaxTau,B,T,Zero,Mean,Disp)

%Preliminaries
if nargin<8
	Zero='y';
end
if nargin<9
	Mean='n';
end
if nargin<10
	Disp='y';
end

%Analysis parameters
Ts=1/Fsd;
MaxLag=ceil(MaxTau/1000*Fsd);

%Computing Correlation using fast algorithm that only considers coincident
%spikes. I attempted to use find(X1~=0 & X2~=0) inside the loop. Howerver,
%this search is way too slow and needs to be performed 2*MaxLag+1 times.
count=1;
R=[];
M=0;    %Number of samples averaged for correlation
while (count-1)*B<T

    %Selecting Indeces for a specified data block
    index1=find(spet1/Fs>B*(count-1)& spet1/Fs<=B*count & spet1/Fs<T);
    index2=find(spet2/Fs>B*(count-1)-MaxTau & spet2/Fs<=B*count+MaxTau & spet2/Fs<T);
    i1=floor(spet1(index1)/Fs*Fsd)+1;   %Floor is used so that the sampled spike train
    i2=floor(spet2(index2)/Fs*Fsd)+1;   %is identical as that produced by SPET2IMPULSE

    Rtemp=zeros(1,2*MaxLag+1);
    for k=-MaxLag:MaxLag

        %Finding Bins with coincident spikes
        i12=sort([i1 i2+k]);    %Index containing spike time entries for shifted and unshifted spike trains
        m=find(diff(i12)==0);   %This finds indeces for coincident spikes. This search is different and 
                                %faster than XCORRSPIKEFAST

        %Computing correlation
        Rtemp(k+MaxLag+1)=length(m)*Fsd^2;  %Computing only for coincident spikes

    end

    %Summing Correlation for each block
    R=[R;Rtemp];
    M=M+ceil(Fsd*B);
    count=count+1;
end    

%Summing and Normalizing Correlation
D=-MaxLag:MaxLag;
for k=1:size(R,1)
    R(k,:)=R(k,:)./(M-abs(D));     %Unbiased estimator - see documentation for XCORR normalization
end
Rb=R*size(R,1);   %Normalized for the number of blocks, so that mean(Rb)==R
R=sum(R,1);

%Removing Center Bin
if length(spet1)==length(spet2) & strcmp(Zero,'y')
    i=find(spet1/Fs<=T & spet1/Fs>0);
    lambda=length(i)/T;
    VarPois=lambda*Fsd; %Variance for Poisson
    %VarPois=lambda*Fsd-lambda^2;    %Variance for Poisson
    R(MaxLag+1)=R(MaxLag+1)-VarPois;
end

%Removing Mean if desired
if strcmp(Mean,'y')
    M1=length(spet1)/T;
    M2=length(spet2)/T;
    R=R-M1*M2;
    Rb=Rb-M1*M2; 
end

%Plotting X-Correlation
if strcmp(Disp,'y')
	plot((-MaxLag:MaxLag)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
	pause(0)
end