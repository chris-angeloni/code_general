%
%function [R,Rb]=xcorrspikeb2(spet1,spet2,Fs,Fsd,MaxTau,B,T,Zero,Mean,Disp)
%
%   FILE NAME   : XCORR SPIKE B2
%   DESCRIPTION : X-Correlation Function of Spike Train Performed
%                 By binning the Spike Train into Blocks and
%                 Averaging individual X-Corr. This function is
%                 similar to XCORRSPIKEB except that it uses the
%                 overlap add method to prevent edge artifacts at
%                 the boundary of the analysis blocks. The results are
%                 essentially identical to XCORRSPIKE.
%
%	spet1,spet2	: Input Spike Event Times
%   Fs          : Samping Rate of SPET
%	Fsd         : Sampling Rate for R(T)
%	MaxTau      : X-Correlation Temporal Lag (sec)
%	B           : Block Size (sec)
%   T           : Spike Train / Experiment Duration (sec)
%	Zero		: Correct the Zeroth Bin when computing
%                 autocorrelation: spet1==spet2
%                 Default: 'y'
%	Mean		: Remove Mean Value
%                 Default : 'n'
%	Disp		: Display : 'y' or 'n'
%                 Default : 'y' 
%
%RETURNED VARIABLES
%
%   R           : Crosscorrelation vector
%   Rb          : Bootstrapped crosscorrelation vectors for each block
%
%(C) Monty A. Escabi, June 2009
%
function [R,Rb]=xcorrspikeb2(spet1,spet2,Fs,Fsd,MaxTau,B,T,Zero,Mean,Disp)

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

%Block Size and Temporal Lag
NB=round(B*Fs);
MaxLag=round(MaxTau*Fs);    %Lag using original sampling rate
MaxLagD=round(MaxTau*Fsd);  %Lag using desired sampling rate

%Converting SPET to a sampled diract impulse array
Ts=1/Fsd;
XX1=spet2impulse(spet1,Fs,Fsd,T);
XX2=spet2impulse(spet2,Fs,Fsd,T);

%Binning and Computing Crosscorrelation
count=1;
R=[];
M=0;    %Number of samples averaged for correlation
%while (count-1)*NB<max(max(spet1),max(spet2)) 
while (count-1)*B<T
%    %Selecting spike times for each block
    index1=find(spet1>NB*(count-1)& spet1<=NB*count);
    index2=find(spet2>NB*(count-1)-MaxLag & spet2<=NB*count+MaxLag);
    %index1=find(spet1/Fs>=B*(count-1)& spet1/Fs<B*count);
    %index2=find(spet2/Fs>=B*(count-1)-MaxTau & spet2/Fs<B*count+MaxTau);
    
    [B*(count-1) B*count]
    [B*(count-1)-MaxTau B*count+MaxTau]
    %index1
%NB*(count-1)
%NB*count
    %Generating Sampled Spike Train and computing correlation for each
    %block
    if ~isempty(index1) & ~isempty(index2)
        X1=spet2impulse(spet1(index1)-NB*(count-1)+MaxLag,Fs,Fsd,B+2*MaxTau);
        X2=spet2impulse(spet2(index2)-NB*(count-1)+MaxLag,Fs,Fsd,B+2*MaxTau);
  
 
        
        NBB=ceil(B*Fsd);
    %NB
%     %    MaxLag
%         figure
%         plot(X1(MaxLag+1:MaxLag+NBB))
%         hold on
%         plot(XX1((count-1)*NBB+1:count*NBB),'r')
%         %plot(XX1,'r')
%         %size(XX1((count-1)*NBB+1:count*NBB))
%         %size(X1(MaxLag+1:NBB+MaxLag))
%         hold off
%         figure
%         plot(xcorr(XX1((count-1)*NBB+1:count*NBB),X1(MaxLagD+1:NBB+MaxLagD),200))
%         %plot(xcorr(XX1,X1(MaxLag+1:NBB+MaxLag),50))
% 
%         %size(XX1((count-1)*NBB+1:count*NBB))
%        %size(X1(MaxLag+1:NBB+MaxLag))
%plot(XX1((count-1)*NBB+1:count*NBB)-X1(MaxLag+1:NBB+MaxLag))
plot(XX1((count-1)*NBB+1:count*NBB)-X1(MaxLagD+1:NBB+MaxLagD))
%hold on
%plot(X1(MaxLagD+1:NBB+MaxLagD),'r')
%hold off
%         pause
%         
%         
        %XX1=[X1(NB*(count-1)+1:NB*count)];
        %XX2=X2(NB*(count-1)+1-MaxLag:NB*count+MaxLag);
        
        %Need to fix SPET2IMPULSE - we are getting differnt samping using
        %above approach
        

        if Mean=='y'
            Rtemp=xcorrfft(X1-mean(X1),X2-mean(X2),MaxLagD);
        else
            Rtemp=xcorrfft(X1,X2,MaxLagD);
        end
    else
        Rtemp=zeros(1,MaxLagD*2+1);
    end

    %Summing Correlation for each block
    R=[R;Rtemp];
    M=M+ceil(Fsd*B);
    count=count+1;
end

%Summing R
Rb=R/ceil(Fsd*B);   %Normalized for the length of each block, so that mean(Rb)==R
R=sum(R,1);

%Substracting Zeroth Bin if Desired when spet1==spet1
if length(spet1)==length(spet2) & strcmp(Zero,'y')
%    N=length(spet1)				%Number of Spikes
   N=sum(X1*Ts);
    VarPois=N/Ts^2;				%Variance for Poisson 
    R(MaxLagD+1)=R(MaxLagD+1)-VarPois;
end

%Normalizing for Mean
D=-MaxLagD:MaxLagD;
R=R./(M-abs(D));     %Unbiased estimator - see documentation for XCORR normalization  


M
Fsd
MaxLagD

%Plotting X-Correlation
if strcmp(Disp,'y')
	plot((-MaxLagD:MaxLagD)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
	pause(0)
end