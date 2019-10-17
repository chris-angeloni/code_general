%
%function [InfoData]=infwordrasterperiodicdtfm(RASTER,Fsd,FMAxis,sig,T)
%
%   FILE NAME       : INF WORD RASTER PERIODIC DT FM
%   DESCRIPTION     : Entropy & Noise Entropy of a periodic Spike Train 
%                     obtained from the rastergram by computing the 
%                     Probability Distribution, P(W|t,s), of finding a B 
%                     letter Word, W, in the Spike Train at time T for a
%                     given periodic stimulus, s.
%                   
%                     The entropy is computed at multiple spike train 
%                     time-scales (sig) and modulation frequencies (FM) 
%                     using a procedure similar to Panzeri et al.
%                     For each time-scale, a specifid ammount of
%                     jitter is added to the spike train, which removes
%                     temporal details finer than the jitter.
%
%   RASTER          : Rastergram - contains multiple trials and multiple
%                     modulation frequencies which are ordered sequential.
%                     See RASTERGENPNBSAM for format.
%   Fsd             : Desired Sampling Rate used to generate words and 
%                     generating P(W) and P(W,t)
%   FMAxis          : Modulation Frequency Array (Hz)
%   sig             : Vector containing the uniformly distributed jitter
%                     paramter. Sig corresponds to the range of jitter (in
%                     ms) used to distort the spike times in RASTER.
%   T               : Amount of time to remove at begning of file to avoid
%                     adaptation effects (sec). Rounds off to assure that a
%                     intiger number of cycles are removed.
%
%Returned Variables
%
%   InfoData        : Data structure containing all mutual information
%                     results
%
%                     .HWordt   : Noise Entropy per Word
%                     .HSect    : Noise Entropy per Second
%                     .HSpiket  : Noise Entropy per Spike
%                     .HWord    : Entropy per Word
%                     .HSec     : Entropy per Second
%                     .HSpike   : Entropy per Spike
%                     .Rate     : Mean Spike Rate
%                     .Ibias    : Information bias in bits/word
%                     .FMAxis   : Modulation frequency axis (Hz)
%                     .sig      : Spike timing jitter added to spike train
%                                 (msec)
%                     .W        : Coded words for entropy calculation
%                     .Wt       : Coded words for noise entropy calculation
%                     .P        : Word distribution function
%                     .Pt       : Word distribution function for noise entropy
%                     .dt       : Actual Temporal Resolution Used

%
% (C) Monty A. Escabi, Dec. 2012
%
function [InfoData]=infwordrasterperiodicdtfm(RASTER,Fsd,FMAxis,sig,T)

%Initializing Matrices
HWord=[];
HWordt=[];
HWordS=[];
HWordtS=[];
HSpike=[];
HSpiket=[];
HSpikeS=[];
HSpiketS=[];
HSec=[];
HSect=[];
HSecS=[];
HSectS=[];
Rate=[];
RateS=[];

%Computing Information
NTrial=length(RASTER)/length(FMAxis);
clear InfoData InfoDataS Info 
for k=1:length(FMAxis)

    %Finding Raster and computing information for k-th Fm
    RAS=RASTER(1+(k-1)*NTrial:NTrial+(k-1)*NTrial);
    B(k)=ceil(1/FMAxis(k)*Fsd);
    [Info]=infwordrasterperiodicdt(RAS,B(k),FMAxis(k),sig,T);

    %Organizing Data into Matrix Format
    HWord=[HWord; Info.HWord];
    HWordt=[HWordt; Info.HWordt];
    HSpike=[HSpike; Info.HSpike];
    HSpiket=[HSpiket; Info.HSpiket];
    HSec=[HSec; Info.HSec];
    HSect=[HSect; Info.HSect];
    Rate=[Rate; Info.Rate];
end

%Appending data to structure
InfoData.HWordt=HWordt;
InfoData.HSect=HSect;
InfoData.HSpiket=HSpiket;
InfoData.HWord=HWord;
InfoData.HSec=HSec;
InfoData.HSpike=HSpike;
InfoData.Rate=Rate;
InfoData.Ibias=(InfoData.HWord(:,end)-InfoData.HWordt(:,end))*ones(1,length(sig));

%InfoData.dt=dt;
InfoData.FMAxis=FMAxis;
InfoData.sig=sig;