%
%function [PLI,PLI1,PLI2]=strfpli2(taxis,STRF1,STRF2,Wo,PP)
%
%       FILE NAME       : STRF PLI2
%       DESCRIPTION     : Computes the STRF rate normalized phase locking
%                         index (PLI): 
%
%                               PLI=STRF ENERGY / Spike Rate
%                         
%                         Also separates out channel 1 and 2 so that we
%                         obtain two additional independent PLI for channel
%                         1 and 2. Requires significant STRF.
%
%       taxis           : Time Axis (sec)
%       STRF1           : Spectro-Temporal Receptive Field (channel 1)
%       STRF2           : Spectro-Temporal Receptive Field (channel 2)
%       Wo              : Zeroth Order Kernel ( Number of Spikes / Sec )
%       PP              : Power Level
%
%RETURNED VALUES
%
%       PLI             : Phase Locking Index (channel 1 & 2 Combined)
%       PLI1            : Phase Locking Index (channel 1)
%       PLI2            : Phase Locking Index (channel 2)
%
%   (C) M. Escabi, July 2006 (Edit Jan 2008)
%
function [PLI,PLI1,PLI2]=strfpli2(taxis,STRF1,STRF2,Wo,PP)

%Estimating Average STRF Ouput for Contra, Ipsi, and Both Channels Combined
Fst=1/(taxis(2)-taxis(1));
[Std]=strfstd(STRF1,STRF2,PP,Fst);
[Std1]=strfstd(STRF1,zeros(size(STRF1)),PP,Fst);
[Std2]=strfstd(STRF2,zeros(size(STRF2)),PP,Fst);

%Phase Locking Index
PLI=Std/Wo;             %Contra & Ipsi
PLI1=Std1/Wo;           %Contra
PLI2=Std2/Wo;           %Ipsi