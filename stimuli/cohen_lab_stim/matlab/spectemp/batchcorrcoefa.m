%
%function []=batchcorrcoefa(header,M,L)
%
%       FILE NAME       : CORR COEF AGRAM
%       DESCRIPTION     : Computes the cross band coerrelation coefficient
%			  for the audiogram
%
%	header		: File name header
%	M		: Data block size
%	L		: Number of blocks to use (Default=inf)
%
%RETURNED VALUES
%
%	R		: Correlatoin Coefficient Matrix
%
function []=batchcorrcoefa(header,M,L)

