%
%function [dBAxis,SPLAxis,Var,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,Disp)
%
%       FILE NAME       : DB VS SPL
%       DESCRIPTION     : Generates the VAR and MEAN Contrast vs. Intensity
%			  Response Curve for Ripple Noise at Multiple
%                         MdB and SPL
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
%	dBAxis		: Modulation Axis
%	SPLAxis		: Intensity Axis
%	Var		: Var Matrix as a function of dB vs SPL
%	Mean		: Mean Matrix as a function of dB vs SPL
%
function [dBAxis,SPLAxis,Var,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,Disp)

%Input Arguments
if nargin<8
	Disp='y';
end

%Generating dB VS. SPL Tunning Curve
N3=length(SPL);
Meant=zeros(N3,5);
Vart=zeros(N3,5);
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
		X=1/Fsd*spet2impulse(spetblock,Fs,Fsd);

		%Finding Mean and Var for Each Block
		M(k)=mean(X);
		V(k)=var(X);
	end

	%Averaging over several presentations (Blocks)
	for k=1:Ncopy
		N=(k-1)*5+1:k*5;
		Meant(l,:)=Meant(l,:)+M(N)/Ncopy;
		Vart(l,:)=Vart(l,:)+V(N)/Ncopy;	
	end
end

%Re-Sequencing the dB vs SPL Matrix
Mean(:,1)=Meant(:,2);
Mean(:,2)=Meant(:,4);
Mean(:,3)=Meant(:,1);
Mean(:,4)=Meant(:,3);
Mean(:,5)=Meant(:,5);
Var(:,1)=Vart(:,2);
Var(:,2)=Vart(:,4);
Var(:,3)=Vart(:,1);
Var(:,4)=Vart(:,3);
Var(:,5)=Vart(:,5);
SPLAxis=SPL';
dBAxis=[0 15 30 45 60];

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
