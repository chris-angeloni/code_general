%
%function []=batchspectempenv(f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M)
%
%       FILE NAME       : BATCH SPEC TEMP ENV
%       DESCRIPTION     : Computes the Spectro-Temporal Envelope
%			  of a Sound 
%			  Saved to outfile
%			  Note: Sound is pre-whitened prior to
%			  performing spectrogeam analysis
%
%       filename        : Input File Name
%       f1              : Lower frequency (array) used for analysis
%       f2              : Upper frequency (array) used for analysis
%       df              : Frequency Window Resolution (Hz)
%                         Note that by uncertainty principle
%                         (Chui and Cohen Books)
%                         dt * df > 1/pi
%                         Equality holding for the gaussian case!!!
%       UT              : Temporal upsampling factor fo stfft
%                         Increases temporal sampling resolution.
%                         Must be a positive integer. 1 indicates
%                         no upsampling.
%       UF              : Frequncy upsampling factor stfft
%                         Increases spectral sampling resolution.
%                         Must be a positive integer. 1 indicates
%                         no upsampling.
%       Fs              : Sampling Rate
%       win             : 'sinc', 'sincfilt', 'gauss' : Optional Default=='sinc'
%       ATT             : Attenution / Sidelobe error in dB (Optional)
%                         Default == 100 dB, ignored if win=='gauss'
%       TW              : Filter Transition Width: If win=='sinc' or 'gauss'
%                         This value is set to zero
%       method          : Method used to determine spectral and temporal
%                         resolutions - dt and df
%                         '3dB'  - measures the 3dB cutoff frequency and
%                                  temporal bandwidth
%                         'chui' - uses the uncertainty principle
%                         Default == '3dB'
%       N               : Polynomial order for pre-whitening ( Default = 2 )
%       M               : Block size to compute STFFT
%                         Default: 1024*32
%                         Note that M/Fs is the time resolution f the
%                         contrast distribution
%
function []=batchspectempenv(f1,f2,df,UT,UF,Fs,win,ATT,TW,method,N,M)

if nargin<10
	method='3dB';
end
if nargin<11
	N=2;
end
if nargin<12
	M=1024*32;
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

%Batching SPEC TEMP ENV
if length(f1)==1
	f1=f1*ones(1,size(Lst,1));
	f2=f2*ones(1,size(Lst,1));
end
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.sw');
	filename=[ Lst(k,1:index-1) '.sw'];
	if exist(filename)
		f=['spectempenv(filename,f1(k),f2(k),df,UT,UF,Fs,win,ATT,TW,method,N,M);'];
		disp(f);
		eval(f);
	end
end
