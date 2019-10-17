%
%function [H,Cxx,Ryx] = wienermimoblock(X,Y,N,M)
%	
%	FILE NAME       : WIENER MIMO BLOCK
%	DESCRIPTION 	: Multi input multi output Wiener filter
%
%                       H = Cxx^-1 * Ryx
%
%                     where Cxx is the input covariance matrix, Ryx is the
%                     crosscorrelation matrix between the outputs and
%                     inputs, and H is the multi-input multi-output Wiener
%                     filter matrix. The elements of H (hkl) correspond to
%                     sub-vectors each of which represents the impulse
%                     response between the k-th input and the l-th output.
%
%                     This program is similar to WIENERMIMO except that the
%                     analysis is performed in blocks of size M
%
%   X               : Multi input matrix (Nx1xNx2) - the number of rows
%                     (Nx1) correspond to the number of inputs. Nx2
%                     corresponds to the number of time samples. Can be a
%                     sparse matrix.
%   Y               : Multi output matrix (Ny1xNy2) - the nunmber of rows
%                     (Ny1) corersponds to the number of outputs. Ny2
%                     corresponds to the number of time samples. Typically
%                     Nx2==Ny2. Can be a sparse matrix.
%   N               : Determines the number of impulse response samples.
%                     Half the filter order.
%                     Note that input covariance matrix has 2*N+1 samples
%                     and the impulse response order for each input is
%                     2*N+1
%   M               : Block size for analysis (number of samples)
%
%RETURNED VARIABLES
%   H               : Multi-input multi-ouput impulse response matrix. The
%                     matrix contains subvectors hkl for each input-ouput
%                     mapping.
%   Cxx             : Input covariance matrix
%   Ryx             : Output-Input cross correlation function 
%
%                     Note that the impulse response is computed as
%
%                          H=pinv(Cxx)*Ryx;
%
% (C) Monty Escabi - 5/4/14
%
function [H,Cxx,Ryx] = wienermimoblock(X,Y,N,M)

%Filter Order
N=2*N;

%Generating Cxx,Ryx, and H - analysis performed 
Cxx=zeros((N+1)*size(X,1),(N+1)*size(X,1));
Ryx=zeros((N+1)*size(X,1),size(Y,1));
for i=1:length(Y)/M
    
    %kth input-output segments
    Xt=full(X(:,(1:M)+M*(i-1)));
    Yt=full(Y(:,(1:M)+M*(i-1))); 
    
    %Cross-Covariance Matrix
    for k=1:size(Xt,1)
        for l=1:size(Xt,1)
            spet1=find(Xt(k,:));
            spet2=find(Xt(l,:));
            MaxTau=N*1000/10000;
            B=30;
            T=size(X,2)/10000;
            Ctemp=toeplitz(xcorrspikesparseb(spet1,spet2,10000,10000,MaxTau,B,T,'n','y','n'));
            Cxxtemp=Ctemp(N+1:2*N+1,1:N+1);             
            Cxx((k-1)*(N+1)+1:k*(N+1),(l-1)*(N+1)+1:l*(N+1))=Cxx((k-1)*(N+1)+1:k*(N+1),(l-1)*(N+1)+1:l*(N+1))+Cxxtemp;
        end
    end
    
    %Cross-Correlation Matrix
    for k=1:size(Xt,1)
        for l=1:size(Yt,1)
            ryxtemp=xcorr(Yt(l,:),Xt(k,:),N/2)';
            Ryx((k-1)*(N+1)+1:k*(N+1),l)=Ryx((k-1)*(N+1)+1:k*(N+1),l)+ryxtemp;
        end
    end

end

%Impulse Response
H=pinv(Cxx)*Ryx;