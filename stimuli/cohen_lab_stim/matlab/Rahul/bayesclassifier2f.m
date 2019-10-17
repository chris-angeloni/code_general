%
%function [ValidClass] = bayesclassifier2f(ClassData,M,L)
%
%	FILE NAME 	: BAYES CLASSIFIER 2F
%	DESCRIPTION : Performs naive bayesian classification using two features.
%                 Returns results as a confusion matrix
%
%	ClassData(k): Data structure vector containing all of the class PATHs
%                 and features
%
%                 .PATH - directory for each class
%                 .F1m  - Feature 1 model data
%                 .F2m  - Feature 2 model data
%                 .F1v  - Feature 1 validation data
%                 .F2v  - Feature 2 validation data
%
%   M           : Number of consecutive samples used to generate featuer
%                 vectors
%   L           : Number of iterations used for classification
%
%   RETURNED VARIABLES
%
%   ValidClass          : Validated class matrix of dimensions: input x output x L
%                         The confusion matrix is obtained as:
%
%                         CM= sum(ValidClass,3)/size(ValidClass,3);
%
% (C) Monty A. Escabi, April 2014 (Edit Oct 2014; May 2016)
%
function [ValidClass] = bayesclassifier2f(ClassData,M,L)

%Generating Joint Featuer distributions - model
Nclass=length(ClassData);
for j=1:Nclass
    
    %Generating Model Distribution
    [f1,f2,N]=hist2(ClassData(j).F1m,ClassData(j).F2m,-50:50,0:40,'n');
    ClassData(j).Pm=N/sum(sum(N));      %Model Distribution
    

    %Fitting Distribution using a Gaussian Mixture Model
    X=[ClassData(j).F1m' ClassData(j).F2m'];
    ClassData(j).GMModel = fitgmdist(X,2);
    
    %Replacing zero valued points with GMM data
    [n,m]=find(ClassData(j).Pm==0);
    for k=1:length(m)
        ClassData(j).Pm(n(k),m(k))=pdf(ClassData(j).GMModel,[f1(m(k)) f2(n(k))]);
    end
        
    %Normalizing for unit area - MAE May 2016
    ClassData(j).Pm=ClassData(j).Pm/sum(sum(ClassData(j).Pm));
    
end

%Validation
ValidClass=zeros(Nclass,Nclass,L);
for j=1:Nclass  %Statistics sent to classifier (input)
    j;
    %Validation Data length
    Nv(j)=length(ClassData(j).F1v);
    
    %Validating
%    index = randsample(Nv(j)-M,L)+M;
    for k=1:L       %Number of itterations for validation

        index(k) = randsample(Nv(j)-M,1)+M; %With replacement - samples one at a time - 10/27/14 - allows you to do more iterations than there are samples
        Ptot=ones(1,Nclass);
        for m=1:M       %Number of validation samples
                i1=round(ClassData(j).F1v(index(k)-m+1))+51;
                i2=round(ClassData(j).F2v(index(k)-m+1));
                
                for l=1:Nclass      %Validation assignment (output)        
                    Ptot(l)=Ptot(l)*(ClassData(l).Pm(i2,i1));
                end
                Ptot=Ptot/max(Ptot);        %normalized probability - assures that for large M Ptot does not exceed resolution of mantisa
        end
        
        %Finding selected/validated class
        i=find(max(Ptot)==Ptot);
        ValidClass(j,i(1),k)=1;         %Choose the first element - length(i) > 1 if the probabilities are equal - ME 10/27/14
        
    end
end