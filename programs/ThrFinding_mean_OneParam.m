
function [Results,meanE]=ThrFinding_mean_OneParam(NumOfSegments_test,NumOfTest_test,SCORE_test,NumOfSegments_imp,SCORE_imp)

T=0.5;
%-----------------------------------------
min_t  = -0.5;
max_t  = 1;
nStep_t =100;
step_t = (max_t-min_t)/nStep_t;
%-----------------------------------------
for i=1:size(SCORE_imp,1)
    MED(i)=median(SCORE_imp(i,:));
    MAD(i)=median(abs(SCORE_imp(i,:)-MED(i)));
end
c=3;
MaxDiffer_FAFR=0.1;
%-----------------------------------------
I=sum(NumOfTest_test);
I2=size(NumOfSegments_imp,2);
k=1;
cls=[];
for i=1:size(NumOfTest_test,2)
    cls(1,k:k+NumOfTest_test(i)-1)=i;
    k=k+NumOfTest_test(i);
end
FA=[]; FR=[];
%-----------------------------------------
nt=0;
NumSpeaker=size(NumOfTest_test,2);
FA_s=[];FR_s=[]; EER_s=[]; metric_s=[];

for t =  min_t :step_t : max_t
    nt=nt+1
    %-------------
    j = 1;   jj = 0;
    NFR(1:NumSpeaker)=0;
    for i = 1:I
        j = jj+1;   jj = j+NumOfSegments_test(i)-1;
        scr= ComparisionThreshold(t,c,MAD(cls(i)),MED(cls(i)),SCORE_test(:,j:jj)');
        if scr(cls(i))<T
            NFR(cls(i))=NFR(cls(i))+1;
        end
    end
    for i=1:NumSpeaker
        FR_s(i,nt) = NFR(i)/ NumOfTest_test(i)*100;
    end
    %--------------
    j = 1;   jj = 0;
    NFA(1:NumSpeaker)=0;
    for i = 1:I2
        j = jj+1;   jj = j+NumOfSegments_imp(i)-1;
        for k=1:size(NumOfTest_test,2)
            scr= ComparisionThreshold(t,c,MAD(k),MED(k),SCORE_imp(:,j:jj)');
            if scr(k)>=T
                NFA(k)=NFA(k)+1;
            end
        end
    end
    for i=1:NumSpeaker
        FA_s(i,nt) = (NFA(i)/I2)*100;
    end
    %--------------
    for i=1:NumSpeaker
        EER_s(i,nt) = (FA_s(i,nt)+FR_s(i,nt))/2;
        metric_s(i,nt)  = abs(FA_s(i,nt)-FR_s(i,nt));
    end
end
%-----------------------------------------



%-----------------------------------------
meanE=0;
Results=[];
for n=1:NumSpeaker
    Error_EER=[];
    Index=[];
    L=0;
    Differ_FAFR=MaxDiffer_FAFR;
    while isempty(Error_EER)
        for k=1:nt
            if  metric_s(n,k)<Differ_FAFR
                L=L+1;
                Index(L,1)=k;
                Error_EER(L)=(FA_s(n,k)+FR_s(n,k))/2;
            end
        end
        Differ_FAFR=Differ_FAFR*2;
    end
    
    [a,b]=min(Error_EER);
    nT=Index(b,1);
    minError=(FA_s(n,nT)+FR_s(n,nT))/2;
    Min_metric=metric_s(n,nT);
    Thershold       = (nT-1) * step_t + min_t;
    meanE=meanE+minError;
    Results(n,1:5)=[minError,Min_metric,Thershold,MED(n),MAD(n)];
end
meanE=meanE/NumSpeaker;
%-----------------------------------------

