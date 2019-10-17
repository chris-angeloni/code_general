%
%function [STRFData]=rtwstrfdbcontbootall(SpecFile,T,data,SPL,MdB,NBlocks,sprtype,NBoot)
%
%   FILE NAME   : RT WSTRF DB CONT BOOT
%   DESCRIPTION : Spectro-temporal receptive field from SPR file using a 
%                 continuous field potential response (no spike train). The
%                 STRF is broken up into NBoot time segments so that it can
%                 subsequently be bootstrapped across time segments.
%
%   SpecFile	: Spectral Profile File
%   T           : Evaluation delay interval for STRF(T,F), T>0 (msec)
%   data        : Matrix containgin neural response and triggers
%   SPL         : Signal RMS Sound Pressure Level
%   MdB         : Signal Modulation Index in dB
%   NBlocks     : Number of Blocks Between Displays
%   sprtype     : SPR File Type : 'float' or 'int16'
%                 Default=='float'	
%   NBoot       : Number of STRF Bootstrap time segments (Default==25)
%
%	RETURNED VALUES 
%   
%   STRFData    : Data Structure containing the following elements
%                 .taxis   - Time Axis
%                 .faxis   - Frequency Axis (Hz)
%                 .STRF1A  - STRF for channel 1 on trial A
%                 .STRF2A  - STRF for channel 2 on trial A
%                 .STRF1B  - STRF for channel 1 on trial B
%                 .STRF2B  - STRF for channel 2 on trial B
%                 .STRF1As - Phase Shuffled STRF for channel 1 on trial A
%                 .STRF2As - Phase Shuffled STRF for channel 2 on trial A
%                 .STRF1Bs - Phase Shuffled STRF for channel 1 on trial B
%                 .STRF2Bs - Phase Shuffled STRF for channel 2 on trial B
%                 .SPLN  - Sound Pressure Level per Frequency Band
%
% (C) Monty A. Escabi, July 2010
%
function [STRFData]=rtwstrfdbcontbootall(SpecFile,T,data,SPL,MdB,NBlocks,sprtype,NBoot)

%Finding Triggers
Fss=125000/14/30;
X=reshape(data(197:210,:),1,14*size(data,2));
[TrigTimes]=trigfindcont(X,0.10);
if TrigTimes>1805
    [TrigTimesA,TrigTimesB]=trigfixstrf2(TrigTimes,400,1799);
    TrigTimesA=round(TrigTimesA/14);
    TrigTimesB=round(TrigTimesB/14);
else
    [TrigTimesA]=trigfixstrf(TrigTimes,400,1799);
    TrigTimesA=round(TrigTimesA/14);    
end

%Looping over electrodes
for k=1:196
   
    %Neural Recording for k-th channel
    Y=data(k,:);

    %Computing STRF and Shuffled STRF for trial A
    [STRFDataA(k)]=rtwstrfdbcontboot(SpecFile,T,Y,TrigTimesA,Fss,SPL,MdB,NBlocks,sprtype,NBoot);
    [STRFDataAs(k)]=rtwstrfdbcontboot(SpecFile,T,Y,TrigTimesA,Fss,SPL,MdB,NBlocks,sprtype,NBoot,'y');
    
    %Computing STRF and Shuffled STRF for trial B
    if exist('TrigTimesB')
        [STRFDataB(k)]=rtwstrfdbcontboot(SpecFile,T,Y,TrigTimesB,Fss,SPL,MdB,NBlocks,sprtype,NBoot);
        [STRFDataBs(k)]=rtwstrfdbcontboot(SpecFile,T,Y,TrigTimesB,Fss,SPL,MdB,NBlocks,sprtype,NBoot,'y');
    end
    
    %Combing Data into a single structure
    STRFData(k).taxis=STRFDataA(k).taxis;
    STRFData(k).faxis=STRFDataA(k).faxis;
    STRFData(k).STRF1A=STRFDataA(k).STRF1;
    STRFData(k).STRF1As=STRFDataAs(k).STRF1;
    STRFData(k).STRF2A=STRFDataA(k).STRF2;
    STRFData(k).STRF2As=STRFDataAs(k).STRF2;
    STRFData(k).SPLN=STRFDataA(k).SPLN;
    if exist('TrigTimesB')
        STRFData(k).STRF1B=STRFDataB(k).STRF1;
        STRFData(k).STRF1Bs=STRFDataBs(k).STRF1;
        STRFData(k).STRF2B=STRFDataB(k).STRF2;
        STRFData(k).STRF2Bs=STRFDataBs(k).STRF2;
    end
    pause(0.1)
    
end
