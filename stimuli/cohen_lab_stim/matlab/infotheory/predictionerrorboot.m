%
%function [Err]=predictionerrorboot(RASTERm,RASTERc)
%
%       FILE NAME       : PREDICTION ERROR BOOT
%       DESCRIPTION     : Bootstraps the normalized prediction error from
%                         which the model and cell noise are removed. Uses 
%                         the routine PREDICTIONERROR 
%
%       RASTERm         : Model Rastergram
%       RASTERc         : Cell Rastergram
%
%OUTPUT
%       Err             : Normalized Percent Error
%
function [Err]=predictionerrorboot(RASTERm,RASTERc,Fs,NB)

%Bootstrapping Error Estiamtion
for k=1:NB
    
    %Displaying 
    clc
    disp(['Bootstrap Trial ' int2str(k) ' of ' int2str(NB)]);

    %Computing Prediction Error
    N=floor(size(RASTERm,1)/2)*2;
    index1=bootrsp(1:N,1);
    index2=bootrsp(1:N,1);
    Err(k)=predictionerror(RASTERm(index1,:),RASTERc(index2,:),Fs);

end