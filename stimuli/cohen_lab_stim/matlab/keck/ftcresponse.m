%
%function [FTC] = ftcresponse(dtcfile,Trig,spet,Fs,Fss,MinT,MaxT,att)
%
%   FILE NAME   : FTC RESPONSE
%   DESCRIPTION : Uses spikesorted SPET data and DTC file to find a 
%                 single unit frequency tunning curve
%
%   dtcfile     : DTC File
%   Trig        : Trigger Times
%   spet        : Spike Event Times
%   Fs          : Spet and Trig Sampling Rates
%   Fss         : Sampling rate for FTC temporal histogram
%   MinT        : Minimum delay to measure response (msec)
%   MaxT        : Maximum delay to measure response (msec)
%   att         : External attenuation setting 
%
%RETURNED VARIABLES
%
%   FTC         : Tunning Curve Data Structure
%                 .Fs       - Sampling Rate
%                 .Freq     - Frequency Axis
%                 .Level    - Sound Level Axis (dB)
%                 .time     - Time axis (msec)
%                 .data     - Data matrix
%                 .NFTC     - Number of FTC repeats
%                 .T1       - FTC Window start time (msec)
%                 .T2       - FTC Window end time (msec)
%
% (C) Monty A. Escabi, Edited Aug. 2007
%
function [FTC] = ftcresponse(dtcfile,Trig,spet,Fs,Fss,MinT,MaxT,att)

%Cehckin For 675 Triggers
if length(Trig)==675 

	%Loading Randon Frequency-Amplitude Order Used for Stimulus Presentation
	load rndlist

	%Finding 1 msec resolution and Maximum delay
	N1=floor(MinT/1000*Fss);
	N2=floor(MaxT/1000*Fss);
	dN=round(Fs/Fss);

	%Finding Responses following Trigger at 1 msec resolution up to MaxT 
	for l=N1:N2
		for k=1:length(Trig)
			index=find(Trig(k)+dN*(l-1)<spet & spet<Trig(k)+dN*l);
			R(k,l-N1+1)=length(index);
		end
	end

	%Extract FTC Data from SPET Array
	FTC=zeros(15,45);
	for l=N1:N2
		for k=1:675
            %data(pseudorand(k,2),pseudorand(k,1),l-N1+1)=R(k,l-N1+1);   %Edited FTC->data, Escabi Aug 2007
			data(pseudorand(k,1),pseudorand(k,2),l-N1+1)=R(k,l-N1+1);   %Edited FTC->data, Escabi Aug 2007
		end
	end

	%Finding Frequency and SPL Axis from DTC File
	%If attenuators are set to 0 dB the maximum spl is 105 dB
	fid=fopen(dtcfile, 'r', 'a');
	H1=fread(fid, 70, 'char');    %read file legend as 16 bit character
	H2=fread(fid, 1, 'short');    %read the rest of header
	H3=fread(fid, 6, 'float');    %fmin, octaves, fmax, ampl, window, flag
	H4=fread(fid, 81, 'short');
	FMin=H3(1);
	Oct=H3(2);
	faxis=FMin*2.^(Oct*(0:44)/44);
	spl=[2.5:(75/14):77.5]+32.5-att; %

    %Converting to data structure format (Escabi Aug, 2007)
    FTC.Freq=faxis;
    FTC.Level=spl;
    FTC.time=(N1:N2)/Fs*dN*1000;    %PSTH time in msec
    FTC.data=data;
    FTC.T1=MinT;
    FTC.T2=MaxT;
    FTC.NFTC=1;
    
else

	%Incorrect Number of Triggers
	disp(['Incorrect Number of Triggers: ' int2str(length(Trig)) ' of 675'])

end
