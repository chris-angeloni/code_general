%
%function [y]=rectwinmodel(beta,time)
%
%
%   FILE NAME       : RECT WIN MODEL
%   DESCRIPTION     : Generates a rectangular window with parameters as
%                     described below
%
%   beta    : Parameter vector where beta = [T1 T2 A1 A2] as defined and
%             illustrated below
%
%             T1 - on time (sec)
%             T2 - off time (sec)
%             A1 - lower amplitude 
%             A2 - upper amplitude
%
%            A2  |---------|
%                |         |
%    A1  ________|         |________
%                T1        T2
%
%	time	: Input time axis in sec
%
%OUTPUT VALUES
%
%	y		: Rectangular pulse output
%
function [y]=rectwinmodel(beta,time)

%Selecting parameters
T1=beta(1);
T2=beta(2);
A1=beta(3);
A2=beta(4);

%Generating Window
y=zeros(1,length(time));
i=find(time<T1);
y(i)=A1*ones(size(i));
i=find(time>T2);
y(i)=A1*ones(size(i));
i=find(time>=T1 & time<=T2);
y(i)=A2*ones(size(i));



