%
%function [I,IS,Rate,dF,dFW]=infcohererasterbias(RASTER,Fsd,df,D,NB)
%
%       FILE NAME   : INF COHERE RASTER BIAS
%       DESCRIPTION : Extrapolates based on data fraction and Fs to 
%                     remove bias from mutual information estimate 
%                     using coherence approach
%
%                     See the Routine: INFCOHERERASTER
%
%       RASTER		: Rastergram data structure - compressed foramt
%                     RASTER.spet : spike event time arrays
%                     RASTER.Fs   : sampling rate
%                     RASTER.T    : stimulus repeat duration (sec)
%       Fsd         : Sampling rate array for generating Coherence
%       df          : Minimum desired frequency resoultion array for
%                     for cross- and auto-spectrum measurements
%       D           : Inverse Data fractions array (Default=1:5)
%       NB          : Number of bootstraps across data segments	
%                     Default==5
%
%RETURNED VARIABLES
%       I           : Mutual Information
%       IS          : Spike Shuffled Mutual Information
%       Rate		: Spike Rate
%       dF          : Array containing frequency resolutions used for
%                     sampling the coherence
%       dFW         : Array containing frequency resolution of window 
%                     function used for coherence analysis
%
%   (C) Monty A. Escabi, Aug. 2005
%
function [I,IS,Rate,dF,dFW]=infcohererasterbias(RASTER,Fsd,df,D,NB)

%Input Arguments
if nargin<7
	D=1:5;
end
if nargin<8
	NB=5;
end

%Extrapolating Over Sampling Rate, Data Fraction, Spectral 
%Resolution, and Number of Bootstraps
Fs=RASTER(1).Fs;
T=RASTER(1).T;
for k=1:length(Fsd)
	for l=1:length(D)
		for m=1:length(df)
			for n=1:NB

			%Display Information
			clc
			disp(['Fsd = ' int2str(Fsd(k))]);
			disp(['D   = ' int2str(D(l))]);
			disp(['df  = ' int2str(df(m))]);
			disp(['NB  = ' int2str(n) ' of ' int2str(NB)]);
		
			
            %Truncating Raster for each data fraction : D(l)
			offset=round((1-1/D(l))*.90*T*rand);
            for i=1:length(RASTER)
                index=find(RASTER(i).spet/Fs<T*1/D(l)+offset & RASTER(i).spet/Fs>offset);
                RASTERD(i).spet=round(RASTER(i).spet(index)-offset*Fs)+1;
                RASTERD(i).Fs=Fs;
                RASTERD(i).T=RASTER(i).T*(1-1/D(1));
            end

            %Computing Information
            [I(k,l,m,n),IS(k,l,m,n),Rate(k,l,m,n),Faxis]=...
				infcohereraster(RASTERD,Fsd(k),df(m));

			%Spectral Resolution
			%Check for consistency with INFCOHERERASTER
			NFFT=2.^nextpow2(Fsd(k)/df(m));
			W=kaiser(NFFT,4.5513)';   
			[d,d,d,dFW(m)]=finddtdfw(W,1000,1024*32);
			dF(m)=mean(diff(Faxis));

			end
		end
	end
end