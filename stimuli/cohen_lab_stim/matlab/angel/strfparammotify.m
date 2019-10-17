function strfparammotify
clear;
load strfparam.mat;
a=[2 2 0 2 0 2 2 2 2 0 0 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 2 2 0 1 2 0 2 0 0 0 0];

for n=1:length(a),
   switch a(n)
   case 1,
        mrx10(n,:)=0;
  		  mrw1(n,:)=0;
   	  mrsf10(n,:)=0;
   	  mrspectrop1(n,:)=0;
   	  mrt10(n,:)=0;
   	  mrc1(n,:)=0;
   	  mrtf10(n,:)=0;
        mrq1(n,:)=0;
        mrbelta1(n,:)=0;
        mrk1(:,n)=0;
        rnx10(n,:)=0;
   	  rnw1(n,:)=0;
   	  rnsf10(n,:)=0;
   	  rnspectrop1(n,:)=0;
   	  rnt10(n,:)=0;
   	  rnc1(n,:)=0;
   	  rntf10(n,:)=0;
   	  rnq1(n,:)=0;
        rnbelta1(n,:)=0;
        rnk1(:,n)=0;
        
     case 2
        mrx20(n,:)=0;
  		  mrw2(n,:)=0;
   	  mrsf20(n,:)=0;
   	  mrspectrop2(n,:)=0;
   	  mrt20(n,:)=0;
   	  mrc2(n,:)=0;
   	  mrtf20(n,:)=0;
        mrq2(n,:)=0;
        mrbelta2(n,:)=0;
        mrk2(:,n)=0;
        rnx20(n,:)=0;
   	  rnw2(n,:)=0;
   	  rnsf20(n,:)=0;
   	  rnspectrop2(n,:)=0;
   	  rnt20(n,:)=0;
   	  rnc2(n,:)=0;
   	  rntf20(n,:)=0;
   	  rnq2(n,:)=0;
        rnbelta2(n,:)=0;
        rnk2(:,n)=0;
     end
  end
  
  save strfparam.mat mrk1 mrk2 rnk1 rnk2 mrx10 mrw1 mrsf10 mrspectrop1 mrt10 mrc1 mrtf10 mrq1 mrbelta1 mrEnoise1 mrE1 mrE1s mrE1a mrE1b mrE1m mrE1am mrE1bm mrErrs1 mrSNR1 mrSI1as mrSI1at mrSI1bs mrSI1bt mrSI1m mrSI1ms mrElps1a mrElps1b mrElpt1a mrElpt1b mralpha_svd1 mralpha_d1 mrx20 mrw2 mrsf20 mrspectrop2 mrt20 mrc2 mrtf20 mrq2 mrbelta2 mrEnoise2 mrE2 mrE2s mrE2a mrE2b mrE2m mrE2am mrE2bm mrErrs2 mrSNR2 mrSI2as mrSI2at mrSI2bs mrSI2bt mrSI2m mrSI2ms mrElps2a mrElps2b mrElpt2a mrElpt2b mralpha_svd2 mralpha_d2 rnx10 rnw1 rnsf10 rnspectrop1 rnt10 rnc1 rntf10 rnq1 rnbelta1 rnEnoise1 rnE1 rnE1s rnE1a rnE1b rnE1m rnE1am rnE1bm rnErrs1 rnSNR1 rnSI1as rnSI1at rnSI1bs rnSI1bt rnSI1m rnSI1ms rnElps1a rnElps1b rnElpt1a rnElpt1b rnalpha_svd1 rnalpha_d1 rnx20 rnw2 rnsf20 rnspectrop2 rnt20 rnc2 rntf20 rnq2 rnbelta2 rnEnoise2 rnE2 rnE2s rnE2a rnE2b rnE2m rnE2am rnE2bm rnErrs2 rnSNR2 rnSI2as rnSI2at rnSI2bs rnSI2bt rnSI2m rnSI2ms rnElps2a rnElps2b rnElpt2a rnElpt2b rnalpha_svd2 rnalpha_d2;

   