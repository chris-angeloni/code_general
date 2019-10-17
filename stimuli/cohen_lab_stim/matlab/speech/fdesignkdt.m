%function  [Beta,N] = fdesignkdt(ATT,dt,Fs)
%
%	FILE NAME       : FEDISGN K DT
%	DESCRIPTION 	: Finds optimal parameters for kaiser window given the
%                     window attenuation (ATT) and desired temporal
%                     resolution dt. In this case, dt = 2 * std(Wt) so that
%                     according to uncertainty principle 
%
%                           dt * df > 1/pi
%
%	ATT             : Attenuation (dB)
%   dt              : Desired temporal resolution (sec)
%	Fs              : Sampling Rate (Hz)
%
%RETURNED PARAMETERS
%
%	N               : Filter Length
%	Beta            : Filter Parameter
%
%   MAE, April 2016
%
function  [Beta,N] = fdesignkdt(ATT,dt,Fs)

%Determining Beta
if ATT >= 50
	Beta=.1102*(ATT-8.7);
end
if ATT <= 21
	Beta=0;
end
if ATT > 21 & ATT < 50
	Beta=.5842*(ATT-21)^.4+.07886*(ATT-21);
end

%Finding Filter Order - Assume that window approximately matches
%uncertainty principle 
%       dt * df = 1/pi
%       
%       where 
%           dt = 2*std(Wt)
%           df = 2*std(Wf)
%
% see Chui and FINDDTDFW
%
TW=2/dt/Fs;
N=ceil((ATT-7.95)/14.36/TW*pi);

%Optimizing for dt - using Chui Approach
dN=ceil(0.25*N);   %Search 25% range of N
N=N-dN:N;
for i=1:length(N)
    W=kaiser(N(i),Beta)';
    [dT(i),dF(i)]=finddtdfw(W,Fs,1024*32);
end
i=find(abs(dT-dt)==min(abs(dT-dt)));
N=N(i);

%Make sure N is an odd number
N=floor(N/2)*2+1;