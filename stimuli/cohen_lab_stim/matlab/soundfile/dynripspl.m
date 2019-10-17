%
%function []=dynripspl(filename,f1,f2,fRP1,fRP2,fRD1,fRD2,MaxA,MinA,MaxT,MinT,MaxdT,beta,gamma,App,RDL,RDU,Rphase,M,Fs,dt,L)
%	
%	FILE NAME 	: dynripsp
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise with 
%			  Spline Window Modulations
%			  Makes L segments of length M and adjoins them into 
%			  Filname
%
%	filename	: File
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	fRP1		: Lower Ripple Phase Frequency
%	fRP2		: Upper Ripple Phase Frequency
%	fRD1		: Lower Ripple Density Frequency
%	fRD2		: Upper Ripple Density Frequency
%
%	MaxA		: Max Alpha
%	MinA		: Min Alpha 
%	MaxT		: Max Window Width 
%	MinT		: Min Window Width
%	MaxdT		: Max Inter Window Width
%
%	beta		: 1 : dB Amplitude Ripple Spectrum
%			  2 : Liner Amplitude Ripple Spectrum
%
%       gamma           : 1 : Random Ripple Phase  
%			  2 : Random Ripple Density 
%			  3 : Random Ripple Phase and Density
%
%       App             : Peak to Peak Riple Amplitude 
%			  if beta ==
%			  1 : App is in dB 
%			  2 : App E [0,1]
%	RDU		: Upper Ripple Density
%	RDL		: Lower Ripple Density
%	RPhase		: Maximum Ripple Phase if gamma==1 or 3
%			  OtherWise Constant Ripple Phase
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	dt		: Temporal window size used for reconstruction
%	L		: Number of segments to adjoin
% 
function []=dynripspl(filename,f1,f2,fRP1,fRP2,fRD1,fRD2,MaxA,MinA,MaxT,MinT,MaxdT,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt,L)


for k=1:L
	disp(['Segment Number: ',num2str(k)])

	%Generating Noise Segment
	[Y,RD,RP,AM,fphase,alpha,T,dT]=dynripsp(f1,f2,fRP1,fRP2,fRD1,fRD2,MaxA,MinA,MaxT,MinT,MaxdT,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt);

	%Saving Parameter Data
	f=['save ',filename,'.',int2str(k),'.mat RD RP fphase alpha T dT'];
	eval(f);

	%Interlacing 2nd Channel - AM
	outdata=zeros(1,2*length(Y));
	outdata(2:2:length(Y)*2)=norm1d(AM).*(-1).^(1:length(AM));
	outdata(1:2:length(Y)*2)=(norm1d(Y)-.5)*2;
	outdata(1:2:length(Y)*2)=outdata(1:2:length(Y)*2)-outdata(1);

	%Normalizing and Interlazing Y
	outdata=round(outdata * .90 * 32768);

	%Putting End of Segment Marker
	outdata(length(Y)*2)=32767;

	%Saving to binary File	
	toint16([filename '.sw'],outdata);

	%Clearing Stack
	clear Y outdata AM RD RP fphase alpha T dT;
end

%Saving Parameters
clear k; 
f=['save ',filename,'.parm.mat'];
eval(f)

%Convert binary file to WAV file
f=['converting ',filename,'.sw to ',filename,'.wav'];
disp(f);
cmdline = sprintf('sox -r %d -c 2 %s.sw %s.wav',Fs, filename, filename);
unix(cmdline); 
