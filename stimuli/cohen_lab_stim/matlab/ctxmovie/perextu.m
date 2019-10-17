%function [Iout] = perextu(Iin)
%
%	FILE NAME 	: PER EXT U
%	DESCRIPTION 	: Generates the Periodic Extension of a uniformly
%			  sampled Map / Image.
%			  
%	Iin		: Input Image NxN
%	Iout		: Output Image 2Nx2N
%
function [Iout] = perextu(Iin)

%Allocating Buffer
Iout=zeros(2*size(Iin));
N=length(Iin)/2;

%Generatin Periodic Extension
Iout(N+1:3*N,N+1:3*N)=Iin;
Iout(N+1:3*N,1:N)=Iin(:,N:-1:1);
Iout(1:N,N+1:3*N)=Iin(N:-1:1,:);
Iout(N+1:3*N,3*N+1:4*N)=Iin(:,2*N:-1:N+1);
Iout(3*N+1:4*N,N+1:3*N)=Iin(2*N:-1:N+1,:);
Iout(1:N,1:N)=Iin(N:-1:1,N:-1:1);
Iout(3*N+1:4*N,1:N)=Iin(2*N:-1:N+1,N:-1:1);
Iout(3*N+1:4*N,3*N+1:4*N)=Iin(2*N:-1:N+1,2*N:-1:N+1);
Iout(1:N,3*N+1:4*N)=Iin(N:-1:1,2*N:-1:N+1);
