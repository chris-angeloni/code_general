%
%function []=sprreconstruct(filename,component)
%
%	
%	FILE NAME 	: SPR RECONSTRUCT
%	DESCRIPTION 	: Reconstructs the Spectral Profiles of a Ripple Noise
%			  Signal
%			  Saves Spectral Profile as a continuous SPR file
%
%	filename	: PARAM Ripple Noise File
%	component	: 'y' or 'n' - break up the RN SPR into separate
%			  MR components which are individually saved
%			  Default=='n'
%
function []=sprreconstruct(filename,component)

if nargin<2
	component='n';
end

%Loading PARAM File
f=['load ' filename];
eval(f)

%Generating Ripple Noise
K=0;
flag=0;		%Marks Last segment
for k=2:N:Mn-N-1

	%Extracting RD and RP Noise Segment 
	RDk    = RD(:,k-1:k+N-1);
	RPk    = RP(:,k-1:k+N-1);

	%Interpolating RD and RP
	MM=length(RDk)-1;
	RDint   = interp10(RDk,3);
	RPint   = interp10(RPk,3);
	RDint   = RDint(:,1:N*LL);
	RPint   = RPint(:,1:N*LL);

	%Generating Ripple Noise SPR FILE
	[SpecProf]=sprgen(f1,f2,RDint,RPint,App,Fs,phase,fphase,K,NB,MaxRD,MaxFM,Axis,DF,component);
	clear RDint RPint

	%Writing Spectral Profile File as 'float' file
	NT=length(taxis);
	NF=length(faxis);
	if component=='n'
		tofloat([filename '.spr'],reshape(SpecProf,1,NT*NF));
	else
		for m=1:NB*NB
			tofloat([filename int2str(m) '.spr'],reshape(SpecProf(:,:,m),1,NT*NF));
		end
	end
	clear SpecProf 

	%Updating Display
	K=K+1;
	clc
	disp(['Segment ' num2str(K) ' Done'])

end

%Closing All Opened Files
fclose('all');
