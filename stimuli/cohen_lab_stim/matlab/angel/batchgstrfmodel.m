%function batchgstrfmodel(dirname,option,svdfile,display);
% 
% Function
%              fit the STRF and batch files (*dB.mat and *Lin.mat) into files (*dB_m.mat and *Lin_m.mat)
%
%INPUT VARIABLES
%	dirname 	: the name of directory that has files named *dB.mat and *Lin.mat
%	option		: 'STRFs'  fit significant STRF
%			  'STRF'   fit STRF
%	svdfile		: Noise SVD Data file. Used todetermine significant SVD threshold.
%	display		: 'y'  display fiited and original STRFs
%			  'n'  do not show anything
%
%  ANQI QIU 
%  11/12/2001
%  Escabi
%  04/17/03

function batchgstrfmodel(dirname,option,svdfile,display);

if nargin<4
   display='n';
end;

D=dir([dirname '*dB.mat']);
[N,M]=size(D);
clear M;

for m=1:N,
   if ~strcmp('',D(m).name)
      infilename=[dirname D(m).name];
      outfilename=[infilename(1:length(infilename)-4) '_m.mat'];
      gstrfmodelsave(infilename,outfilename,'svd',option,svdfile,display);
      disp(infilename);
      pause(2);
      close all;
   end
end

D=dir([dirname '*Lin.mat']);
[N,M]=size(D);
clear M;

for m=1:N,
   if ~strcmp('',D(m).name)
      infilename=[dirname D(m).name];
      outfilename=[infilename(1:length(infilename)-4) '_m.mat'];
      gstrfmodelsave(infilename,outfilename,'svd',option,svdfile,display);
      disp(infilename);
      pause(2);
      close all;
   end
end
