%function  [P,N,alpha,wc] = fdesignmf(Gamma,Bera)
%
%	FILE NAME       : F DESIGN MF
%	DESCRIPTION 	: Finds optimal parameters for Max Flat Escabi / Roark
%                     B-Spline Filter.
%
%   Note:             Nomenclature is ala Kaiser.
%
%	Beta            : Cuttoff Frequency ( 0-pi )
%	Gamma           : Transition Width ( 0-pi )
%
%RETURNED ARGMENTS
%	N               : Filter Length
%	p               : Filter Smoothing Parameter
%	alpha           : Filter Shape Parameter
%   wc              : Cuttoff Frequency ( 0-pi )
%
% (C) Monty A. Escabi, December 2007
%
function  [P,N,alpha,wc] = fdesigmf(Gamma,Beta)

N=ceil(3.66*Beta/pi*(pi/Gamma).^2);
P=Beta/pi*(N+1);
alpha=1;
wc=Beta;
