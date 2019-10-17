%
%function [H,Cxx,Ryx] = wienermimo(X,Y,Fsd,MaxTau,T)
%	
%	FILE NAME       : WIENER MIMO
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
%   X               : Input event time structure. The values in X(k).spet
%                     are the input pulse event times for channel k.
%   X.T             : Experiment duration
%   Y               : Output event time structure. The values in Y(k).spet
%                     are the input pulse event times for channel k.
%   Y.Fs            : Sampling rate
%   N               : Determines the number of impulse response samples.
%                     Half the filter order.
%                     Note that input covariance matrix has 2*N+1 samples
%                     and the impulse response order for each input is
%                     2*N+1
%   Fsd             : Sampling rate for Cxx and Ryx
%RETURNED VARIABLES
%   H               : Multi-input multi-ouput impulse response matrix. The
%                     matrix contains subvectors hkl for each input-ouput
%                     mapping.
%   Cxx             : Input covariance matrix
%   Ryx             : Output - Input cross correlation function
%
%                     Note that the impulse response is computed as
%
%                          H=pinv(Cxx)*Ryx;
%
%
function [H,Cxx,Ryx] = wienermimosparse(X,Y,Fsd,N)

Zero = 'n';
Mean = 'y';
disp = 'n';

Fs = Y(1).Fs;
MaxTau = round(2000*N/Fs);

%Cross-Covariance Matrix
for k=1:size(X,2)
    for l=k:size(X,2)
        Ctemp=toeplitz(xcorrspikesparse(X(k).spet,X(l).spet,Fs,Fsd,MaxTau,X(k).T,Zero,Mean,disp));
        Cxxtemp=Ctemp(N+1:2*N+1,1:N+1);
        Cxx((k-1)*(N+1)+1:k*(N+1),(l-1)*(N+1)+1:l*(N+1))=Cxxtemp;
        Cxx((l-1)*(N+1)+1:l*(N+1),(k-1)*(N+1)+1:k*(N+1))=Cxxtemp;
    end
end

%Cross-Correlation Matrix
for k=1:size(X,2)
    for l=1:size(Y,2)
        ryxtemp=xcorrspikesparse(Y(k).spet,X(l).spet,Fs,Fsd,MaxTau/2,X(k).T,Zero,Mean,disp)';
        Ryx((k-1)*(N+1)+1:k*(N+1),l)=ryxtemp;
    end
end

%Computing MIMO Wiener filter
H=pinv(Cxx)*Ryx;