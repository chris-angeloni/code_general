%
%function [ClassData] = bayesextractfeature(ClassData,DF)
%
%	FILE NAME 	: BAYES EXTRACT FEAUTURE
%	DESCRIPTION : Reads sound stasitics data (contrast and spl) and
%                 organizes into a structure that can be used to perform
%                 Bayesian analysis
%
%	ClassData(k): Data structure vector containing the class data paths
%                 .PATH - directory for each class 
%   DF          : Downsampling factor. Used if the data is oversampled. For
%                 example for the time-varying statistics the Overlap
%                 factor is 90% which corresponds to an oversampling factor
%                 of 10. (DEFAULT == 1)
%
% RETURNED DATA
%
%	ClassData(k): Returned data structure containing all of the class PATH
%                 and features
%
%                 .PATH - directory for each class
%                 .F1m  - Feature 1 model data
%                 .F2m  - Feature 2 model data
%                 .F1v  - Feature 1 validation data
%                 .F2v  - Feature 2 validation data
%
% (C) Monty A. Escabi, April 2014
%
function [ClassData] = bayesextractfeature(ClassData,DF)

%Input Args
if nargin<2
    DF=1;
end

for j=1:length(ClassData)
    
    %Finding Files for generating model and validation data
    List=dir([ClassData(j).PATH '*.mat']);
    clc
    disp(['Loading data from : ' ClassData(j).PATH])
    
    %Initializing ClassData Features - Model and Validation
    ClassData(j).F1m=[];
    ClassData(j).F2m=[];
    ClassData(j).F1v=[];
    ClassData(j).F2v=[];

    for k=1:length(List)

        %Loading Data
        f=['load ' ClassData(j).PATH List(k).name];
        eval(f)
        disp(['          Loading : ' ClassData(j).PATH List(k).name])

        %Feature 1
        N=round((length(AudStatsData.AmpData.MeandB3))/2);
        cm=AudStatsData.AmpData.MeandB3(1:N);        %grabbing first half for generating model
        cv=AudStatsData.AmpData.MeandB3(N+1:end);    %grabbing second half for validation
        ClassData(j).F1m=[ClassData(j).F1m cm(1:DF:end)];     %Feature 1 - model - mean spl
        ClassData(j).F1v=[ClassData(j).F1v cv(1:DF:end)];     %Feature 1 - validation

        %Feature 2
        N=round((length(AudStatsData.AmpData.StddB3))/2);
        em=AudStatsData.AmpData.StddB3(1:N);         %grabbing first half for genreating model
        ev=AudStatsData.AmpData.StddB3(N+1:end);     %grabbing second half for validation
        ClassData(j).F2m=[ClassData(j).F2m em(1:DF:end)];     %Feature 2 - model - contrast standard dev      
        ClassData(j).F2v=[ClassData(j).F2v ev(1:DF:end)];     %Feature 2 - validation

    end
end