%
%function [Xa,Ya] = soundcalibalign(X,Y)
%
%	FILE NAME 	: SOUND CALIB ALIGN 
%	DESCRIPTION 	: Aligns the input and output waveorms
%
%	X		: White Noise Input Vector
%	Y		: System Output Vector
%
%RETURNED DATA
%
%	Xa		: Aligned Input Waveform
%	Ya		: Aligned Output Waveform
%
function [Xa,Ya] = soundcalibalign(X,Y)

%Truncating
N=min(length(X),length(Y));
X=X(1:N);
Y=Y(1:N);

%Determine delay
M=1024*64;
R=xcorr(Y(1:1024*256),X(1:1024*256),M);
plot(R)
i=find(max(abs(R))==abs(R));
delay=i-M-1;
Xa=X(1:N-delay);
Ya=Y(delay+1:N);








%R=xcorr(X(1:1024*256),Y(1:1024*256),M);
%i=find(max(abs(R))==abs(R));
%delay=M-i+1


%delay=i-M-1


%Shifting and Truncating
%if strfind(version,'6.5')
%    Xa=X(1:length(X)-delay);
%    Ya=Y(delay+1:length(Y));
%else   
%    Ya=Y(1:N-delay);
%    Xa=X(delay+1:N);
     %Xa=X(1:N-delay);
     %Ya=Y(delay+1:N);
%Xa=X(1:N+delay);
%Ya=Y(1-delay:N);

 
    %end

