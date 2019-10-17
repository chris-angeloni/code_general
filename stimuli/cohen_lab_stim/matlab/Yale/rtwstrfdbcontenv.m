%
%function [STRFData]=rtwstrfdbcont(SpecFile,T,Y,f1e,f2e,Trig,Fss,SPL,MdB,NBlocks,sprtype,shuffle)
%
%   FILE NAME   : RT WSTRF DB CONT
%   DESCRIPTION : Spectro-temporal receptive field from SPR file using a 
%                 continuous field potential response (no spike train).
%                 Uses the response envelope within a band [f1 f2] as the
%                 response for crosscorrelation.
%
%   SpecFile	: Spectral Profile File
%   T           : Evaluation delay interval for STRF(T,F), T>0 (msec)
%   Y           : Continuous Neural Response
%   f1d         : Lower envelope cutoff frequency (Hz)
%   f2d         : Upper envelope cutoff frequency (Hz)
%   Trig		: Array of Trigger Times
%   Fss         : Sampling Rate for Neural Response (Y) and Trig
%   SPL         : Signal RMS Sound Pressure Level
%   MdB         : Signal Modulation Index in dB
%   NBlocks     : Number of Blocks Between Displays
%   sprtype     : SPR File Type : 'float' or 'int16'
%                 Default=='float'	
%   shuffle     : Flag for computing a shufled STRF. The neural data is shuffled so that
%                 it has identical power spectrum but random phase prior to computing
%                 the STRF
%
%RETURNED VALUES 
%   
%   STRFData    : Data Structure containing the following elements
%                 .taxis - Time Axis
%                 .faxis - Frequency Axis (Hz)
%                 .STRF1 - Spectro-Temporal Receptive Field for channel 1
%                 .STRF2 - Spectro-Temporal Receptive Field for channel 2
%                 .SPLN  - Sound Pressure Level per Frequency Band
%
% (C) Monty A. Escabi, Jan 2012
%
function [STRFData]=rtwstrfdbcont(SpecFile,T,Y,f1e,f2e,Trig,Fss,SPL,MdB,NBlocks,sprtype,shuffle)

%Parameters
if nargin<9
	sprtype='float';
end
if nargin<10
	shuffle='n';
end

%Trigger Length
NTrig=length(Trig);

%Loading Parameter Data
index=findstr(SpecFile,'.spr');
ParamFile=[SpecFile(1:index(1)-1) '_param.mat'];
f=['load ' ParamFile];
eval(f);
clear App  MaxFM XMax Axis MaxRD RD f phase Block Mn RP f1 f2 Mnfft FM N fFM fRD NB NS LL filename M X fphase Fsn
FsE=Fs/DF;  %Sound Envelope sampling rate

%Converting Temporal Delays to Sample Numbers
Nd=round(T/1000*Fs/DF);
 
%Opening Spectral Profile File
fid=fopen(SpecFile);

%Resampling Neural Response
Y=double(Y);
P=round(FsE*14*30);
Q=round(Fss*14*30);
P=round(FsE*1E10);
Q=round(Fss*1E10);
YY=resample(Y,P,Q);

%Filtering Neural Data to extract envelope
H=bandpass(f1e,f2e,2,Fss,60,'n');
N=(length(H)-1)/2;
YL=conv(YY,H);
YL=YL(N+1:length(YL)-N);
YL(1:N)=fliplr(YL(N+1:2*N));                    %Removing Edge Artifact
YL(end-(0:N-1))=fliplr(YL(end-(N:2*N-1)));      %Removing Edge Artifact 
if strcmp(shuffle,'y')
	YL=randphasespec(YL);
end
YL=abs(hilbert(YL));                            %Extracting the response envelope within [f1 f2]

%Reading first two segments SPR Segments
S2=MdB*(fread(fid,NT*NF,sprtype)+0.5);
S2=reshape(S2,NF,NT);
S3=MdB*(fread(fid,NT*NF,sprtype)+0.5);
S3=reshape(S3,NF,NT);

%Generating STRF
clc
STRF1=zeros(NF,NT+2*Nd);
STRF2=zeros(NF,NT+2*Nd);
for k=2:NTrig-1                                     %Discard 1st and last block for overlap add

    %Extracting Envelope for kth block. 
    S1=S2;
    S2=S3;
    S3=MdB*(fread(fid,NT*NF,sprtype)+0.5);
    S3=reshape(S3,NF,NT);
    S=[S1(:,NT+(-Nd+1:0)) S2 S3(:,1:Nd)];           %Envelope from adjacent blocks is concatenated for overlap add method

    %Extracting Respone for kth block and resampling
    %Zeros appended at extremities for overlap add method
    Yk=[zeros(1,Nd) YL(round(Trig(k)*P/Q):round(Trig(k)*P/Q)+size(S2,2)-1) zeros(1,Nd)]; 
    YYk=ones(size(S,1),1)*Yk;
    Y2k=fliplr([zeros(1,Nd) YL(round(Trig(NTrig-k+1)*P/Q):round(Trig(NTrig-k+1)*P/Q)+size(S2,2)-1) zeros(1,Nd)]);
    YY2k=ones(size(S,1),1)*Y2k;
 
    %Cross Correlating and Generating STRF. Uses Overlap add method with ciruclar convolution.
    STRF1=STRF1+real(ifft( conj(fft(S,[],2)).*fft(YYk - mean(mean(YYk)),[],2 ),[],2));
    STRF2=STRF2+real(ifft( conj(fft(S,[],2)).*fft(YY2k - mean(mean(YY2k)),[],2),[],2));

    %Displaying Output
    if k/NBlocks==round(k/NBlocks)
        clc
        disp(['Percent Done: ' num2str(k/(NTrig-2)*100,2) '%'] )
        subplot(211)
        imagesc((1:size(STRF1,2))/FsE,log2(faxis/faxis(1)),real(STRF1)),colorbar,set(gca,'YDir','normal'),pause(0)
        subplot(212)
        imagesc((1:size(STRF1,2))/FsE,log2(faxis/faxis(1)),real(STRF2)),colorbar,set(gca,'YDir','normal'),pause(0)
    end
   
end

%Faster to flip STRF2 at this point. Technically we need to flip S to compute 
%STRF2. Instead, I am flipping Y2k since its a vector and its much faster.
STRF2=fliplr(STRF2);

%Normalizing STRFs
NB=NTrig-2;                     %Number of blocks analyzed, first and last are discarded because of overlap add method
dt=1/FsE;                       %Sampling Resolution
Var=MdB^2/8;					%Variance for Moving Ripple
STRF1=1/NB/dt*fftshift(STRF1,2)*dt/Var;
STRF2=1/NB/dt*fftshift(STRF2,2)*dt/Var;

%Truncating STRF
STRF1=STRF1(:,((NT+2*Nd)/2-Nd:(NT+2*Nd)/2+Nd));
STRF2=STRF2(:,((NT+2*Nd)/2-Nd:(NT+2*Nd)/2+Nd));

%Data Structure
STRFData.taxis=(-Nd:Nd)/FsE;
STRFData.faxis=faxis;
STRFData.STRF1=STRF1;
STRFData.STRF2=STRF2;
STRFData.SPLN=SPL-10*log10(NF);     % Normalized SPL per frequency band

%Closing all opened files
fclose all
