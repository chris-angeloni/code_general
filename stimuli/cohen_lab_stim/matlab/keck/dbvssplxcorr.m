%
%function [dBAxis,SPLAxis,Xcorr]=dbvssplxcorr(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,T,ZeroBin,Disp)
%
%       FILE NAME       : DB VS SPL XCORR
%       DESCRIPTION     : Generates the spike train xcorr for 
%			  Ripple Noise at Multiple MdB and SPL
%
%	spet		: Spike Event Time Array
%	Trig2		: Input Double Trigger Time Vector
%	Trig3		: Input Tripple Trigger Time Vector
%	SPL		: Sound Pressure Level Array
%	Fs		: Sampling Rate for SPET and Trig2, Trig3
%	Fsd		: Sampling Rate used to Compute Spike Train Statistics
%	Ncopy		: Number of Copies used in FLOAT2WAVDBVSSPL
%	T		: X-correlation temporal lag ( sec )
%	ZeroBin		: Fix Zeroth Bin for dB vs. SPL X-Correlation 
%			  Default : 'n' 
%	Disp		: Display : 'y' or 'n' , Default == 'n'
%
%Returned Variables
%
%	dBAxis		: Modulation Axis
%	SPLAxis		: Intensity Axis
%	Var		: Var Matrix as a function of dB vs SPL
%	Mean		: Mean Matrix as a function of dB vs SPL
%
function [dBAxis,SPLAxis,Xcorr]=dbvssplxcorr(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,T,ZeroBin,Disp)

%Input Arguments
if nargin<9
	ZeroBin='n';
end
if nargin<10
	Disp='n';
end

%Generating dB VS. SPL Tunning Curve
N3=length(SPL);
xcorrdbspl=[];
for l=1:N3
	for k=1:Ncopy*5

		%Finding Spikes for Each Block
		L=5*Ncopy;	%Number of Triggers at a single intensity
		if k<Ncopy*5
			index=find(spet>=Trig2((l-1)*L+k) & spet<Trig2((l-1)*L+k+1));
		else
			index=find(spet>=Trig2((l-1)*L+k) & spet<Trig2((l-1)*L+k)+mean(diff(Trig2(1:Ncopy*5))));
		end
		spetblock=[spet(index)-Trig2((l-1)*L+k) mean(diff(Trig2(1:Ncopy*5)))];

		%Finding xcorr for Each Block
%		X=spet2impulse(spetblock,Fs,Fsd);
%		xcorrb(k,:)=xcorr(X,X,round(T*Fsd));		
		xcorrb(k,:)=xcorrspike(spetblock,spetblock,Fs,Fsd,T,ZeroBin,Disp);
	end

	%Averaging x-corr over several presentations (Blocks)
	xcorrdb=zeros(5,size(xcorrb,2));
	for k=1:Ncopy
		count=1;
		for j=(k-1)*5+1:k*5
			xcorrdb(count,:)=xcorrdb(count,:)+xcorrb(j,:);
			count=count+1;
		end
	end

	%Combining for all Intensities
	xcorrdbspl=[xcorrdbspl;xcorrdb];

end

%Re-Sequencing the dB vs SPL Matrix
for k=1:N3
	Xcorr((k-1)*N3+1,:)=xcorrdbspl((k-1)*N3+2,:);
	Xcorr((k-1)*N3+2,:)=xcorrdbspl((k-1)*N3+4,:);
	Xcorr((k-1)*N3+3,:)=xcorrdbspl((k-1)*N3+1,:);
	Xcorr((k-1)*N3+4,:)=xcorrdbspl((k-1)*N3+3,:);
	Xcorr((k-1)*N3+5,:)=xcorrdbspl((k-1)*N3+5,:);
end
SPLAxis=SPL';
dBAxis=[0 15 30 45 60];

%Displaying if Desiredxis,SPLAxis,Var,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy)
if ~strcmp(Disp,'n')

	%Finding Amplitude and Temporal Ranges 
	Max=1.2*max(max(Xcorr));
	Min=min(min(Xcorr));
	N=floor(size(Xcorr,2)/2);
	taxis=(-N:N)/Fsd;
	for k=1:5*N3

			subplot(N3,5,k)
			plot(taxis,Xcorr(k,:),'b')
			axis([ min(taxis) max(taxis) Min Max])

	end
end	
