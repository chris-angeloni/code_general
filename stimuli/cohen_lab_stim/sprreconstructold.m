%
%function []=sprreconstructold(filename,component)
%
%	
%	FILE NAME 	: SPR RECONSTRUCT OLD
%	DESCRIPTION 	: Reconstructs the Spectral Profiles of a Ripple Noise
%			  Signal
%			  Saves Spectral Profile as a continuous SPR file
%			  Use this Routine To reconstruct MR and RN sounds
%			  prior to 1999
%			  Use SPRRECONSTRUCT otherwise
%
%	filename	: PARAM Ripple Noise File
%	component	: 'y' or 'n' - break up the RN SPR into separate
%			  MR components which are individually saved
%			  Default=='n'
%
function []=sprreconstructold(filename,component)

if nargin<2
	component='n';
end

%Loading PARAM File
f=['load ' filename];
eval(f)

%Generating Ripple Noise
K=0;
flag=0;		%Marks Last segment
for k=2:N-1:Mn-N-1

	%Extracting RD and RP Noise Segment 
	RDk    = RD(:,k-1:k+N-2);
	RPk    = RP(:,k-1:k+N-2);

	%Interpolating RD and RP
	MM=length(RDk);
	RDint   = interp10old(RDk,3);
	RPint   = interp10old(RPk,3);

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
