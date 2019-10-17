%
% function [FTCStats] = ftccentroid(FTC,alpha,RegN,RegM)
%
%   FILE NAME   : FTC CENTROID
%   DESCRIPTION : Computes the centroid (mean), standard deviation, and 
%                 skewness of an FTC at each SPL (log frequency). Also 
%                 performs an optional regularity check to make sure that 
%                 consecutive frequency samples have signficant data.
%
%                 NOTE: PREVIOUSLY REQUIRED THRESHOLDED FTC AS INPUT. NOW
%                 USES NON THRESHOLDED FTC DATA.
%
%   FTC         : Tunning Curve Data Structure
%                 FTC.Freq  - Frequency Axis
%                 FTC.Level - Sound Level Axis (dB)
%                 FTC.data  - Data matrix
%   alpha       : Desired significance value when thresholding the tunning
%                 curve data (Default=0.05)
%   RegN        : Minimum number of significant samples required for regularity
%                 analysis. At least RegN samples need to be present within
%                 a windown of size RegM x RegM for a point to be
%                 considered real (OPTIONAL, Default=3)
%   RegM        : Window size for regularity analysis (M x M). 
%                 (OPTIONAL, Default==3)
%
% RETURNED DATA
%
%   FTCstats    : FTC statistics Data Structure
%                 .Mean         - Mean Frequency (Hz)
%                 .Std          - Standard Deviation (Octaves)
%                 .StdHz        - Standard Deviation (Hz)
%                 .Skewness     - Skewness at each SPL
%                 .Threshold    - Attenuation response threshold (dB)
%                 .CF           - Characteristic Frequency (Hz)
%                 .Mask         - Regularity Mask. Takes values of NaN if the
%                                 FTC did not exceed the regularity criterion
%                                 at a given SPL, 1 if it did satisfy it.
%
% (C) Monty A. Escabi, Last Edit July 2007
%
function [FTCStats] = ftccentroid(FTC,alpha,RegN,RegM)

%Input Arguments
if nargin<2
   alpha=0.05; 
end
if nargin<3
    RegN=4;
end
if nargin<4
    RegM=3;
end
RegM=odd(RegM);


%Regularity Check - Requires that at least RegN significant samples exists within 
%a window of size RegM x RegM
%W=ones(RegM,RegM);
%W=conv2(ceil(FTC.data/max(max(FTC.data))),W);
%ND=(RegM-1)/2;
%W=W(1+ND:size(W,1)-ND,1+ND:size(W,2)-ND);
%W=floor(W/(RegN-1)*.9);
%W=ceil(W/max(max(W)));
%FTCStats.Mask=ceil(sum(W)/max(sum(W)))';
%index=find(FTCStats.Mask==0);
%FTCStats.Mask(index)=nan(size(index));

%Thresholding Tuning Curve
[FTCt,Mean,RegMask] = ftcthreshold(FTC,alpha,RegN,RegM);
FTCStats.Mask=RegMask;

%Computing Mean
Data=FTCt.data;
X=log2(FTCt.Freq/min(FTCt.Freq));
FTCStats.Mean=Data'*X'./sum(Data)';
FTCStats.Mean=min(FTCt.Freq)*2.^(FTCStats.Mean);
index=find(isnan(FTCStats.Mean));
FTCStats.Mask(index)=nan(size(index));

%Computing Standard Deviation
XX=ones(length(FTCStats.Mean),1)*X - log2(FTCStats.Mean/min(FTCt.Freq))*ones(size(X));
FTCStats.Std=sqrt( sum(Data'.*XX.^2,2) ./sum(Data)' ) ;

%Computing Standard Deviation in Hz (Aug 2012)
XX=ones(length(FTCStats.Mean),1)*FTCt.Freq - FTCStats.Mean*ones(size(X));
FTCStats.StdHz=sqrt( sum(Data'.*XX.^2,2) ./sum(Data)' ) ;

%Computing Skewness
FTCStats.Skewness= (sum(Data'.*XX.^3,2) ./sum(Data)') ./ FTCStats.Std.^3 ;

%Finding Threshold and CF
index=find(~isnan(FTCStats.Mask));
FTCStats.Threshold=FTC.Level(min(index));
FTCStats.CF=FTCStats.Mean(min(index));
