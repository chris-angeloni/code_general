%
%function [H] = wienerfftmultitrial(X,Y,beta,N)
%
%	FILE NAME 	: WIENER FFT
%	DESCRIPTION	: Optimal Wiener Filter Estimate for multi-trial input-
%                 output data.Derived using frequency domain estimator.
%                 Shuffles data across trials to estimate Sxx in order to
%                 remove measurement noise in x(t). This is done only if X
%                 is a matrix containing multiple trials.
%
%   X           : Input Signal Matrix (Lx x M). Lx is the number of trials
%                 and M is the number of samples. Assumes that
%                 deterministic component is constant across trials. Noise
%                 is variable across trials.
%   Y           : Output Signal (Ly x M). Ly is the number of trials and M
%                 is the number of samples. 
%   beta        : Kaiser window smoothing factor
%   N           : Filter order
%
% (C) Monty A. Escabi, December 2008
%
function [H] = wienerfftmultitrial(X,Y,beta,N)

%Data Dimmensions
NFFT=pow2(nextpow2(max(length(X),length(Y))));
Lx=size(X,1);
Ly=size(Y,1);
M=size(X,2);

%Generating Window Matrix
%W=kaiser(NFFT,beta);
W=zeros(NFFT,1);
W(1:M)=kaiser(M,beta);  %Zero Padded Window
Wx=[];
Wy=[];
for k=1:Lx
    Wx=[Wx W];  %Trials arranged along columns
end
for k=1:Ly
    Wy=[Wy W];  %Trials arranged along columns
end

%Frequency Domain Approximation To Wiener Filter - shuffling data across
%trials
X=[X zeros(Lx,NFFT-length(X))]';    %Append Zeros and Transpose
Y=[Y zeros(Ly,NFFT-length(Y))]';    %Append Zeros and Transpose
X=fft(X.*Wx,NFFT);                  %Transposed FFT - Trials arranged as row vectors
Y=fft(Y.*Wy,NFFT);                  %Transposed FFT - Trials arranged as row vectors
for k=1:Lx
    for l=1:Ly
        Syx(k,l,:)=X(:,k).*conj(Y(:,l));
    end
end
if Lx>1                             %Multiple Trials
    count=1;
    for k=1:Lx
        for l=1:Lx
            if k~=l
                Sxx(count,:)=abs(X(:,k)).^2;
                count=count+1;
            end
        end
    end
else                                %Only One Trials
    Sxx(1,:)=abs(X(:,1)).^2;
end
%Syx=squeeze(mean(mean(Syx,1),2));      %Average across trials
Syx=squeeze(sum(sum(Syx,1),2))/Lx/Ly;   %Average across trials
Sxx=squeeze(mean(Sxx,1))';              %Average across trials - removes off diagonals
H=real(ifft(Syx./Sxx,NFFT))';
H=fliplr(H);
H=[H(length(H)) H(1:N-1)];
