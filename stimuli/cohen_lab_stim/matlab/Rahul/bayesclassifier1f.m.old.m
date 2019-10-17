%
%function [ValidClass] = bayesclassifier1f(ClassData,Feature,M,L)
%
%	FILE NAME 	: BAYES CLASSIFIER 1F
%	DESCRIPTION : Performs naive bayesian classification using one features.
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
%   Feature     : Selected featuer (1 or 2)
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
% (C) Monty A. Escabi, April 2014 (Edit Nov 2014)
%
function [ValidClass] = bayesclassifier1f(ClassData,Feature,M,L)

%Generating Joint Featuer distributions - model
Nclass=length(ClassData);
for j=1:Nclass
    
    %Generating Model Distribution
    if Feature==1
        [N]=hist(ClassData(j).F1m,-50:50);
        ClassData(j).Pm=N/sum(N);      %Model Distribution
    else
        [N]=hist(ClassData(j).F2m,0:40);
        ClassData(j).Pm=N/sum(N);      %Model Distribution
    end
    
end

%Validation
if Feature==1
    ValidClass=zeros(Nclass,Nclass,L);
    for j=1:Nclass  %Statistics sent to classifier (input)

        %Validation Data length
        Nv(j)=length(ClassData(j).F1v);

        %Validating
        %index = randsample(Nv(j)-M,L)+M;
        for k=1:L       %Number of itterations for validation

            index(k) = randsample(Nv(j)-M,1)+M; %With replacement - samples one at a time - 10/27/14 - allows you to do more iterations than there are samples
            Ptot=ones(1,Nclass);
            for m=1:M       %Number of validation samples
                    i1=round(ClassData(j).F1v(index(k)-m+1))+51;

                    for l=1:Nclass      %Validation assignment (output)        
                        if (ClassData(l).Pm(i1)==0 & j==l)
                            Ptot(l)=Ptot(l);
                        else
                            Ptot(l)=Ptot(l)*(ClassData(l).Pm(i1));
                        end
                    end
                    Ptot=Ptot/max(Ptot);        %normalized probability - assures that for large M Ptot does not exceed resolution of mantisa
            end

            %Finding selected/validated class
            i=find(max(Ptot)==Ptot);
            ValidClass(j,i,k)=1;

        end
    end
else
    ValidClass=zeros(Nclass,Nclass,L);
    for j=1:Nclass  %Statistics sent to classifier (input)

        %Validation Data length
        Nv(j)=length(ClassData(j).F2v);

        %Validating
        %index = randsample(Nv(j)-M,L)+M;
        for k=1:L       %Number of itterations for validation
            index(k) = randsample(Nv(j)-M,1)+M; %With replacement - samples one at a time - 10/27/14 - allows you to do more iterations than there are samples

            Ptot=ones(1,Nclass);
            for m=1:M       %Number of validation samples
                    i2=round(ClassData(j).F2v(index(k)-m+1));

                    for l=1:Nclass      %Validation assignment (output)        
                        if (ClassData(l).Pm(i2)==0 & j==l)
                            Ptot(l)=Ptot(l);
                        else
                            Ptot(l)=Ptot(l)*(ClassData(l).Pm(i2));
                        end
                    end
                    Ptot=Ptot/max(Ptot);        %normalized probability - assures that for large M Ptot does not exceed resolution of mantisa
            end

            %Finding selected/validated class
            i=find(max(Ptot)==Ptot);
            ValidClass(j,i(1),k)=1;         %Choose the first element - length(i) > 1 if the probabilities are equal - ME 10/27/14
        
        end
    end
    
end