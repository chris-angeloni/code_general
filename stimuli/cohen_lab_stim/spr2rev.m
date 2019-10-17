%
%function []=spr2rev(sprfile,fintype,Fsd)
%
%       FILE NAME       : SPR 2 REV
%       DESCRIPTION     : Converts an SPR  file to a Reverse Reconstruction
%                         REV file.  This file can then be used to compare
%                         the reconstructed stimulus from the spike train
%
%       sprfile         : Input SPR file name
%       fintype         : SPR File Type: 'float' or 'int16'
%       Fsd             : Desired sampling rate (Hz) for REV file. 
%                         The program automatically adjusts Fsd so that it is a
%                         integer multiple of the number of samples in a single
%                         SPR block (32000). This assures that the samples are
%                         uniformly spaced across blocks.
%
%
%   (C) Monty A. Escabi, Edited July 2006
%
function []=spr2rev(sprfile,fintype,Fsd)

%Opening SPR and Param Files
index=findstr(sprfile,'.spr');
paramfile=[sprfile(1:index-1) '_param.mat'];
f=['load ' paramfile];
eval(f);
fidin=fopen(sprfile,'r');

%Opening REV Files
%for k=1:NF
for k=1:1
    f=['fid' int2strconvert(k,3) '=fopen(''' sprfile(1:index-1) '.rev'''    ',' '''wb''' ');' ];
    eval(f);
end

%Make sure Fsd is an integer multiple of the block size 
Nsamples=ceil(32000/Fs*Fsd);
Fsd=(Nsamples-1)/32000*Fs

%Interpolation Time Axis
DT=32000/Fs;
t=[taxis taxis+DT taxis+2*DT];          %Concatenate three blocks
ti=(0:Nsamples*3-1)/Fsd;                %Interpolated time segment for three blocks

%Converting SPR to REV
NBlocks=M/Fs;            %CHECK
S1=reshape(fread(fidin,NF*NT,fintype,0,'l'),NF,NT);
S2=reshape(fread(fidin,NF*NT,fintype,0,'l'),NF,NT);
S3=reshape(fread(fidin,NF*NT,fintype,0,'l'),NF,NT);
S=[S1 S2 S3];
for k=1:NBlocks-2

	%Displaying Output
	clc
	disp(['Converting Block: ' int2str(k) ' of ' int2str(NBlocks)])

    %Interpolating Frequency Channels and Saving to REV Files 
    %for n=1:NF
    for n=1:1
        
        %Interpolating Individual Channels
        Si = interp1(t,S(n,:),ti,'spline');
        
        %Interpolating Individual Channels and Saving Output REV file
        if k==1
            %Saving Channel Data
            f=['fwrite(fid' int2strconvert(n,3) ', Si(1:Nsamples*2),' '''float''' ');'];
            eval(f);
        elseif k==NBlocks-2
            %Saving Channel Data
            f=['fwrite(fid' int2strconvert(n,3) ', Si(Nsamples+1:Nsamples*3),' '''float''' ');'];
            eval(f);
        else
            %Saving Channel Data            
            f=['fwrite(fid' int2strconvert(n,3) ', Si(Nsamples+1:Nsamples*2),' '''float''' ');'];
            eval(f);
        end
    end
       
    %Reading New Data Block
    if k<NBlocks
        S1=S2;
        S2=S3;
        S3=reshape(fread(fidin,NF*NT,fintype,0,'l'),NF,NT);
        S=[S1 S2 S3];
    end
    
end

%Saving Parameter File
NT=length(Si);
ti=(0:Nsamples-1)/Fsd;
f=['save ' sprfile(1:index-1) '_param_REV.mat Fsd NF NT Nsamples ti'];
eval(f)

%Closing all Files
fclose('all');