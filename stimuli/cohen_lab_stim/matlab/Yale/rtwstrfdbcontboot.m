%
%function [STRFData]=rtwstrfdbcontboot(SpecFile,T,Y,Trig,Fss,SPL,MdB,NBlocks,sprtype,shuffle)
%
%   FILE NAME   : RT WSTRF DB CONT BOOT
%   DESCRIPTION : Spectro-temporal receptive field from SPR file using a 
%                 continuous field potential response (no spike train). The
%                 STRF is broken up into NBoot time segments so that it can
%                 subsequently be bootstrapped across time segments.
%
%   SpecFile	: Spectral Profile File
%   T           : Evaluation delay interval for STRF(T,F), T>0 (msec)
%   Y           : Continuous Neural Response
%   Trig		: Array of Trigger Times
%   Fss         : Sampling Rate for Neural Response (Y) and Trig
%   SPL         : Signal RMS Sound Pressure Level
%   MdB         : Signal Modulation Index in dB
%   NBlocks     : Number of Blocks Between Displays
%   sprtype     : SPR File Type : 'float' or 'int16'
%                 Default=='float'	
%   NBoot       : Number of STRF Bootstrap time segments (Default==25)
%   shuffle     : Flag for computing a shufled STRF. The neural data is shuffled so that
%		  it has identical power spectrum but random phase prior to computing
%		  the STRF
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
% (C) Monty A. Escabi, July 2010
%
function [STRFData]=rtwstrfdbcontboot(SpecFile,T,Y,Trig,Fss,SPL,MdB,NBlocks,sprtype,NBoot,shuffle)

%Parameters
if nargin<9
	sprtype='float';
end
if nargin<10
    NBoot=25;
end
if nargin<11
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
P=round(FsE*14*30);
Q=round(Fss*14*30);
YY=resample(Y,P,Q);

%Filtering Neural Data to get rid of 60 Hz and high frequency noise
f1=2.5;
f2=55;
H=bandpass(f1,f2,2,Fss,60,'n');
N=(length(H)-1)/2;
YL=conv(YY,H);
YL=YL(N+1:length(YL)-N);
YL(1:N)=fliplr(YL(N+1:2*N));			%Removing Edge Artifact
YL(end-(0:N-1))=fliplr(YL(end-(N:2*N-1)));	%Removing Edge Artifact
if strcmp(shuffle,'y')
     YL=randphasespec(YL);
end

%Reading first two segments SPR Segments
S2=MdB*(fread(fid,NT*NF,sprtype)+0.5);
S2=reshape(S2,NF,NT);
S3=MdB*(fread(fid,NT*NF,sprtype)+0.5);
S3=reshape(S3,NF,NT);

%Generating STRF
clc
STRF1=zeros(NF,NT+2*Nd,NBoot);
STRF2=zeros(NF,NT+2*Nd,NBoot);
count=0;
NSegments=floor(NTrig/NBoot);                       %Number of SPR blocks for each bootstrap segment
for k=2:min(NTrig-1,NSegments*NBoot+1)              %Discard 1st and last block for overlap add/

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
    nb=floor(count/NSegments) + 1;      %Bootstrap segment counter
    STRF1(:,:,nb)=STRF1(:,:,nb)+real(ifft( conj(fft(S,[],2)).*fft(YYk - mean(mean(YYk)),[],2 ),[],2));
    STRF2(:,:,nb)=STRF2(:,:,nb)+real(ifft( conj(fft(S,[],2)).*fft(YY2k - mean(mean(YY2k)),[],2),[],2));

    %Displaying Output
    if k/NBlocks==round(k/NBlocks)
        clc
        disp(['Percent Done: ' num2str(k/(NTrig-2)*100,2) '%'] )
        subplot(211)
        imagesc((1:size(STRF1,2))/FsE,log2(faxis/faxis(1)),real(mean(STRF1,3))),colorbar,set(gca,'YDir','normal'),pause(0)
        subplot(212)
        imagesc((1:size(STRF1,2))/FsE,log2(faxis/faxis(1)),real(mean(STRF2,3))),colorbar,set(gca,'YDir','normal'),pause(0)
    end
    
    %Incrementing Counter
    count=count+1;
   
end

%Faster to flip STRF2 at this point. Technically we need to flip S to compute 
%STRF2. Instead, I am flipping Y2k since its a vector and its much faster.
STRF2=flipdim(STRF2,2);

%Normalizing STRFs and Truncating for NBoot segments
STRF1=STRF1(:,:,1:NBoot);
STRF2=STRF2(:,:,1:NBoot);
dt=1/FsE;                       %Sampling Resolution
Var=MdB^2/8;					%Variance for Moving Ripple
STRF1=1/NSegments/dt*fftshift(STRF1,2)*dt/Var;
STRF2=1/NSegments/dt*fftshift(STRF2,2)*dt/Var;

%Truncating STRF
STRF1=STRF1(:,((NT+2*Nd)/2-Nd:(NT+2*Nd)/2+Nd),:);
STRF2=STRF2(:,((NT+2*Nd)/2-Nd:(NT+2*Nd)/2+Nd),:);

%Data Structure
STRFData.taxis=(-Nd:Nd)/FsE;
STRFData.faxis=faxis;
STRFData.STRF1=STRF1;
STRFData.STRF2=STRF2;
STRFData.SPLN=SPL-10*log10(NF);     % Normalized SPL per frequency band

%Closing all opened files
fclose all
