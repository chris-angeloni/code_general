%
%function [RDHist1,FMHist1,RDHist2,FMHist2,Time1,Time2]=rtfhist(paramfile,spet,Trig,Fss,T,Xc)
%
%       FILE NAME       : RTF HIST
%       DESCRIPTION     : RTF Histogram for Moving Ripple Noise
%			  Joint Histogram of RD and FM conditioned on
%			  a spike event
%
%	paramfile	: Moving Ripple Parameter File 
%	spet		: Spike Event Time Array
%	Trig		: Trigger Array
%	Fss		: Sampling Rate for 'spet' and 'Trig'
%	T		: Time Preceeding a Spike to Find RD
%			  and FM parameters
%			  Optional : Default : T=0
%			  Does not seem to make a difference !!!
%	Xc		: Octave center frequency used to remove RD dependendy
%			  on FM.  Xc can be a single element or a two element array
%			  where the 1st element correpsonds to sound channel 1 
%			  and the second element to sound channel 2
%
%			  Optional : Default = log2(MaxRD/MinRD)/2
%			  ( at center of spectro-temporal envelope to 
%			  minimize RMS error across a population )
%
%			  Note that: FM = RD' * Xc + FMd
%			  Where FMd is the desired FM profile and Xc is
%			  presumably the CF of the neuron
%
%			  Note: FM parameter is NOT multiplied by - sign.
%	      		  If one desires to compare RTFHist with RTF must
%			  multiply the FM parameter by a - sign 
%
%RETURNED VARIABLES
%
%	RDHist1,FMHist1	: Ripple Density and Modulation Rate channel 1
%	RDHist2,FMHist2	: Ripple Density and Modulation Rate channel 2
%	Time1, Time2	: Time of Occurence of RD and FM
%
function [RDHist1,FMHist1,RDHist2,FMHist2,Time1,Time2]=rtfhist(paramfile,spet,Trig,Fss,T,Xc)

%Checking Input Arguments
if nargin < 5
	T=0;
end
if nargin < 6
	Xc=log2(20/.5)/2;
end

%Opening Parameter File
f=['load ' paramfile];
eval(f);

%Removing RD dependency of Fm 
if nargin < 6
	FM(1:length(FM)-1)=FM(1:length(FM)-1)+diff(RD)*Fsn*log2(max(faxis)/min(faxis))/2;
else

	%Checking to see if Xc has one or two elements
	if length(Xc)==1
		FM(1:length(FM)-1)=FM(1:length(FM)-1)+diff(RD)*Fsn*Xc;
	else
		FM1(1:length(FM)-1)=FM(1:length(FM)-1)+diff(RD)*Fsn*Xc(1);
		FM2(1:length(FM)-1)=FM(1:length(FM)-1)+diff(RD)*Fsn*Xc(2);
	end
end

%Initializing Time, RD and FM Histograms
RDHist1=[];
FMHist1=[];
RDHist2=[];
FMHist2=[];
Time1   =[];
Time2   =[];

%Finding Spikes for Contra and Ipsi
spet1=spet;
spet2=-spet+max(Trig)+Trig(2);

%Checkinf to see if Xc is one value or two
if length(Xc)==1	%If Xc contains only one value

	%Computing Conditioned Histogram
	for k=2:length(Trig)-1

		%Extracting RD , FM Noise Segment
		RDk    = RD(:,(k-1)*N+2-k:k*N-k+1);
		FMk    = FM(:,(k-1)*N+2-k:k*N-k+1);

		%Finding Spikes in a Block
		if k==2 
			index1=find(spet1<=Trig(k+1) & spet1>=Trig(k));
			index2=fliplr(find(spet2<=Trig(k+1) & spet2>=Trig(k)));
		else
			index1=find(spet1<=Trig(k+1) & spet1>Trig(k));
			index2=fliplr(find(spet2<=Trig(k+1) & spet2>Trig(k)));
		end

		%Finding Histogram Distribution For Contra
		if ~isempty(index1)
			%Finding Spikes Relative to Trigger
			spetk1=spet1(index1)-Trig(k)-T;
	
			%Finding Histograms Distributions
			RDHist1=[RDHist1 RDk(1+floor(spetk1/Fss*Fsn/32*31))];
			FMHist1=[FMHist1 FMk(1+floor(spetk1/Fss*Fsn/32*31))];
	
			%Finding Time of Spike
			Time1=[Time1 spet1(index1)-Trig(1)];
		end
	
		%Finding Histogram Distribution For Ipsi
		if ~isempty(index2)
			%Finding Spikes Relative to Trigger
			spetk2=spet2(index2)-Trig(k)-T;
	
			%Finding Histograms Distributions
			RDHist2=[RDHist2 RDk(1+floor(spetk2/Fss*Fsn/32*31))];
			FMHist2=[FMHist2 FMk(1+floor(spetk2/Fss*Fsn/32*31))];
	
			%Finding Time of Spike
			Time2=[Time2 spet1(index2)-Trig(1)];
		end
	
	end

else	%If Xc for contra and ipsi are specified explicitly ( Xc has 2 values )

	%Computing Conditioned Histogram
	for k=2:length(Trig)-1

		%Extracting RD , FM Noise Segment
		RDk     = RD(:,(k-1)*N+2-k:k*N-k+1);
		FM1k    = FM1(:,(k-1)*N+2-k:k*N-k+1);
		FM2k    = FM2(:,(k-1)*N+2-k:k*N-k+1);

		%Finding Spikes in a Block
		if k==2 
			index1=find(spet1<=Trig(k+1) & spet1>=Trig(k));
			index2=fliplr(find(spet2<=Trig(k+1) & spet2>=Trig(k)));
		else
			index1=find(spet1<=Trig(k+1) & spet1>Trig(k));
			index2=fliplr(find(spet2<=Trig(k+1) & spet2>Trig(k)));
		end

		%Finding Histogram Distribution For Contra
		if ~isempty(index1)
			%Finding Spikes Relative to Trigger
			spetk1=spet1(index1)-Trig(k)-T(1);
	
			%Finding Histograms Distributions
			RDHist1=[RDHist1 RDk(1+floor(spetk1/Fss*Fsn/32*31))];
			FMHist1=[FMHist1 FM1k(1+floor(spetk1/Fss*Fsn/32*31))];
	
			%Finding Time of Spike
			Time1=[Time1 spet1(index1)-Trig(1)];
		end
	
		%Finding Histogram Distribution For Ipsi
		if ~isempty(index2)
			%Finding Spikes Relative to Trigger
			spetk2=spet2(index2)-Trig(k)-T(2);
	
			%Finding Histograms Distributions
			RDHist2=[RDHist2 RDk(1+floor(spetk2/Fss*Fsn/32*31))];
			FMHist2=[FMHist2 FM2k(1+floor(spetk2/Fss*Fsn/32*31))];
	
			%Finding Time of Spike
			Time2=[Time2 spet1(index2)-Trig(1)];
		end
	
	end

end

%Flipping FM2, RD2, Time2 and multiplying FM2 by - sign
RDHist2=fliplr(RDHist2);
FmHist2=-fliplr(FMHist2);	%Beacuse FM2 Parameter Runs Backwards in time
Time2=fliplr(Time2);
