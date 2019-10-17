%
%function []=batchpsdfile(f1,f2,Fs,df,ATT,type,M,Disp,N)
%
%       FILE NAME       : BATCH PSD FILE
%       DESCRIPTION     : Batch for Computing the power spectral density of 
%                         all "sw" files in directory.  Uses periodogram average
%                         described in Hayes
%
%	f1		: Lower cutoff frequency for spectral fit
%	f2		: Upper cutoff frequency for spectral fit
%       Fs              : Sampling Rate
%       ATT             : Stopband and Passband attenuation for smoothing
%                         Roark / Escabi B-Spline Window
%       df              : Spectral Resolution for Periodogram (PSD)
%       type            : Input and Output File Data Type
%                         Default == 'int16'
%       M               : Data Block Size ( Default==1024*128 )
%                         Must be a dyadic number ( 2^L for some L==integer)
%       Disp            : Display output: 'y' or 'n'
%                         Default = 'n'
%       N               : Order of Polynomial fit for Spectrum
%                         Optional - Default = 1
%
function []=batchpsdfile(f1,f2,Fs,df,ATT,type,M,Disp,N)

%Input Arguments
if nargin<9
	N=1;
end 
if nargin<8
	Disp='n';
end 
if nargin<7
	M=1024*128;
end 
if nargin<6
	type='int16';
end

%Preliminaries
more off

%Generating a File List
f=['ls *.sw' ];
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
	for k=1:30
		if k+returnindex(l)<returnindex(l+1)
			Lst(l,k)=List(returnindex(l)+k);
		else
			Lst(l,k)=setstr(32);
		end
	end
end

%Batching PSDFILE
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.sw');
	filename=[ Lst(k,1:index-1) '.sw'];
	if exist(filename)

		%Evaluating Amp Dist and Saving
		psdfile(filename,f1,f2,Fs,df,ATT,type,M,Disp,N,'y');

	end
end
