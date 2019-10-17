%function []=spr2multichannel(fileheader)
%
%   FILE NAME       : SPR 2 MULTI CHANNEL
%   DESCRIPTION     : Converts a SPR file for moving ripple or ripple
%                     noise to a multi channel file. Each channel is
%                     saved seprarately as a matlab file.
%
%   fileheader      : File Header
%
%RETURNED VARIABLES
%
%	None
%
%(C) Monty Escabi, March 2012
%
function []=spr2multichannel(fileheader)

%Initializing files
fid=fopen([fileheader '.spr'],'r');
load([fileheader '_param.mat'])

%Converting SPR to multi channel matlab files
for k=1:NF
   
    frewind(fid)
    count=1;
    S=fread(fid,NT*NF,'float');         %Load first segment
    Sk=[];
    while ~feof(fid)
        
        %Reshaping and storing to Sk
        S=reshape(S,NF,NT);
        Sk=[Sk S(k,:)];                 %Envelope for kth channel
        count=count+1;
        
        %Display Progress 
        clc
        disp(['Converting Channel ' int2str(k) ' of ' int2str(NF) ' :  Block ' int2str(count)])
        
        %Loading next segment
        S=fread(fid,NT*NF,'float');
    end
    
    %Saving segment Sk
    f=['save ' fileheader '_ch' int2strconvert(k,3) ' Sk'];
    eval(f)
    
end