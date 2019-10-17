%
%function [SPLAxis,Var,Mean]=splrlf(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,Disp)
%
%       FILE NAME       : SPL RLF
%       DESCRIPTION     : Generates a Rate Level Function for MR or RN
%			  Response Curve at Multiple SPL
%
%	spet		: Spike Event Time Array
%	Trig2		: Input Double Trigger Time Vector
%	Trig3		: Input Tripple Trigger Time Vector
%	SPL		: Sound Pressure Level Array
%	Fs		: Sampling Rate for SPET and Trig2, Trig3
%	Fsd		: Sampling Rate used to Compute Spike Train Statistics
%	Ncopy		: Number of Copies used in FLOAT2WAVDBVSSPL
%	Disp		: Display : 'y' or 'n' , Default == 'y'
%
%Returned Variables
%
%	SPLAxis		: Intensity Axis
%	Var		: Var Matrix as a function of dB vs SPL
%	Mean		: Mean Matrix as a function of dB vs SPL
%
function [SPLAxis,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,Disp)

%Input Arguments
if nargin<8
	Disp='y';
end

%Generating SPL Rate Level Function
N3=length(SPL);
Meant=zeros(1,N3);
Vart=zeros(1,5);
%for l=1:N3
%	for k=1:Ncopy
%
%		%Finding Spikes for Each Block
	%	L=Ncopy;	%Number of Triggers at a single intensity
	%	if k<Ncopy
	%		index=find(spet>=Trig2((l-1)*L+k) & spet<Trig2((l-1)*L+k+1));
	%	else
	%		index=find(spet>=Trig2((l-1)*L+k) & spet<Trig2((l-1)*L+k)+mean(diff(Trig2(1:Ncopy*5))));
	%	end
	%	spetblock=[spet(index)-Trig2((l-1)*L+k) mean(diff(Trig2(1:Ncopy*5)))];
	%	X=1/Fsd*spet2impulse(spetblock,Fs,Fsd);

%		%Finding Mean and Var for Each Block
%		M(k)=mean(X);
	%	V(k)=var(X);
	%end

	%Averaging over several presentations (Blocks)
	%for k=1:Ncopy
	%	N=(k-1)*5+1:k*5;
	%	Meant(l,:)=Meant(l,:)+M(N)/Ncopy;
	%	Vart(l,:)=Vart(l,:)+V(N)/Ncopy;	
	%end
%end

%Re-Sequencing the dB vs SPL Matrix
%Mean(:,1)=Meant(:,2);
%Mean(:,2)=Meant(:,4);
%Mean(:,3)=Meant(:,1);
%Mean(:,4)=Meant(:,3);
%Mean(:,5)=Meant(:,5);
%Var(:,1)=Vart(:,2);
%Var(:,2)=Vart(:,4);
%Var(:,3)=Vart(:,1);
%Var(:,4)=Vart(:,3);
%Var(:,5)=Vart(:,5);

Trig2=[Trig2 max(Trig2)+Trig2(2)-Trig2(1)];
for k=1:length(Trig2)-1
	index=find(spet>=Trig2(k) & spet<Trig2(k+1));
	M(k)=length(index);
end

Mean(1)=M(1)+M(4)+M(7)+M(10);
Mean(2)=M(2)+M(5)+M(8)+M(11);
Mean(3)=M(3)+M(6)+M(9)+M(12);
Mean(4)=M(13)+M(16)+M(19)+M(22);
Mean(5)=M(14)+M(17)+M(20)+M(23);
Mean(6)=M(15)+M(18)+M(21)+M(24);

SPLAxis=SPL';

%Displaying if Desiredxis,SPLAxis,Var,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy)
if ~strcmp(Disp,'n')
	subplot(211)
	%pcolor(dBAxis,SPLAxis,Mean),shading interp,colormap jet,colorbar
	imagesc(dBAxis,SPLAxis,flipud(Mean)),colormap jet,colorbar
	zlabel('Mean Spike Count in 10 ms Window')
	xlabel('Modulation Depth ( dB )')
	ylabel('SPL ( dB )')
	subplot(212)
	%pcolor(dBAxis,SPLAxis,Var),shading interp,colormap jet,colorbar
	imagesc(dBAxis,SPLAxis,flipud(Var)),colormap jet,colorbar
	zlabel('Var in Spike Count in 10 ms Window')
	xlabel('Modulation Depth ( dB )')
	ylabel('SPL ( dB )')
	pause(0)
end
