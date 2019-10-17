%
%function [fFM,fRD]=findmrparam(MaxRD,MaxFM,MaxX,deltaFM,T,Type,M)
%
%       FILE NAME     	: FIND MR PARAM
%       DESCRIPTION     : Finds the moving ripple parameters necessary 
%			  to achieve certain error in the RTFH
%
%	MaxRD		: Maximum Ripple Density  (Cycles/Octave)
%	MaxFM		: Maximum Modulation Rate (Hz)
%	MaxX		: Maximum Octave Frequency
%	deltaFM		: Temporal Modulation Rate resolution for RTFH (Hz)
%	T		: Receptive Field Length ( sec )
%	Type		: Error criterion used to determine fRD and fFM
%			  1   == based on RMS error ( Default )
%			  2   == based on Maximum error
%			  3.p == uses p percent confidence interval
%			  4   == based on comulative RMS error
%			  5   == based on cumulative max error
%			  6.p == based on p percent confidnce interval
%				 for cumulative error
%	M		: Number of samples used to compute error
%			  distributions ( Default == 1024*16 )
%
function [fFM,fRD]=findmrparam(MaxRD,MaxFM,MaxX,deltaFM,T,Type,M)

%Input Arguments
if nargin<6
	Type=1;
end
if nargin<7
	M=1024*16;
end

%Finding Errors
[StdERD,StdEFM,MaxERD,MaxEFM]=findmrerr(MaxRD,MaxFM,MaxX,T,1,1,M);,close

%Necessary fRD
if Type==1 | Type==4
	fRD=1*deltaFM/2/StdERD;
elseif Type==2 | Type==5
	fRD=1*deltaFM/2/MaxERD;
elseif Type>=3 & Type<4
	p=Type-3;
	Tresh=sqrt(2)*erfinv(1-2*p);
        fRD=1*deltaFM/2/StdERD/Tresh;
elseif Type>=6
	p=Type-6;
	Tresh=sqrt(2)*erfinv(1-2*p);
        fRD=1*deltaFM/2/StdERD/Tresh;
end

%Necessary fFM
if Type==1 | Type==4
	fFM=1*deltaFM/2/StdEFM;
elseif Type==2 | Type==5
	fFM=1*deltaFM/2/MaxEFM;
elseif Type>=3 & Type<4
	p=Type-3;
	Tresh=sqrt(2)*erfinv(1-2*p);
	fFM=1*deltaFM/2/StdEFM/Tresh;
elseif Type>=6
	p=Type-6;
	Tresh=sqrt(2)*erfinv(1-2*p);
	fFM=1*deltaFM/2/StdEFM/Tresh;
end

%Finding Errors
[StdERD,StdEFM,MaxERD,MaxEFM,ERD,EFM]=findmrerr(MaxRD,MaxFM,MaxX,T,fRD,fFM,M);,close

%Finding fFM and fRD if cumulative error is used
if Type==4 | Type>6
	StdEC=std(ERD+EFM);
	fFM=fFM*StdEC/(StdERD+StdEFM);
	fRD=fRD*StdEC/(StdERD+StdEFM);
elseif Type==5
	MaxEC=max(ERD)+max(EFM);
	fFM=fFM*MaxEC/(MaxERD+MaxEFM)
	fRD=fRD*MaxEC/(MaxERD+MaxEFM)
end

%Finding Errors
[StdERD,StdEFM,MaxERD,MaxEFM,ERD,EFM]=findmrerr(MaxRD,MaxFM,MaxX,T,fRD,fFM,M);
