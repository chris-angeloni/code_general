%
% function [X,Y] = readmap(MapFileName,Format)
%
%   FILE NAME   : READ MAP
%   DESCRIPTION : Reads Valery Kalatsky's Image Maps
%
%   MapFileName : Map File Name
%   Format      : Image formaty
%                 1 - magnitude and phase (Default)
%                 2 - real and imaginary
%
% RETURNED DATA
%   X,Y         : Magnitude and Phase matrices if Format == 1
%                 Real and Imaginary matrices if Format  == 2
%
% (C) Monty A. Escabi, Edited May 2006
%
function [X,Y] = readmap(MapFileName,Format)

%Input Arguments
if nargin<2
    Format=1;    
end

%Reading Map Information / Data
fid=fopen(MapFileName,'r');
fread(fid,2,'int16');
Nx=fread(fid,1,'ushort');
Ny=fread(fid,1,'ushort');
X=fliplr(rot90(reshape(fread(fid,Nx*Ny,'double'),Nx,Ny),-1));
Y=fliplr(rot90(reshape(fread(fid,Nx*Ny,'double'),Nx,Ny),-1));

%Converting to Magnitude & Phase format
if Format==1
   M=sqrt(X.^2 + Y.^2);
   P=atan2(Y,X);
%   i=find(P<0);
%   P(i)=P(i)+2*pi;
   X=M;
   Y=P;
end

%Closing File
fclose(fid);