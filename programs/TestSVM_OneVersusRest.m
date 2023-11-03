
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function classifies test super vectors usinf OneVersusRest_SVM
% inputs:
%         DataTestSvm: extracted super vectors of test data
%         classTest: class of each super vectors (of test)
%         ProgramsPath: path of programs
%         Datapath: path of languages' data
%         MatlabSVM_train: if 1 : SVM will be trained with MATLAB function
%         task: 'test'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SCORE=TestSVM_OneVersusRest(pathstates,DataTestSvm,classTest,ProgramsPath,Datapath,MatlabSVM_train,task,NormScrs,NormScrs_target)
load(pathstates);
SVM='LibSVM_train';
classTest(1:end)=1;
DatFile_SVM(DataTestSvm,classTest,ProgramsPath,task);
SCORE=[];
for i=1:(length(dir(Datapath))-2)
    
    if isempty(MatlabSVM_train)
        SVMnew=[SVM,num2str(i),'.libsvm'];
        dos(['svm-predict.exe  -b 1 SVM_test.txt  ',SVMnew,'  SVM-test-OUT.txt']);
        [A,B1,B2]= textread('SVM-test-OUT.txt','%s %f %f');
        if B1(1)==1
            B1(1)=[]; B2(1)=[];
            SCORE=[SCORE;B1'];
        else
            B1(1)=[]; B2(1)=[];
            SCORE=[SCORE;B2'];
        end
    else
        %classes = svmclassify(MatlabSVM_train{1,i},DataTestSvm);
        [out,f] = svmdecision(DataTestSvm,MatlabSVM_train{1,i});
        SCORE=[SCORE;f'];
    end
    
end
%-----
if NormScrs==1
    %---
    SCOREnorm=[];
    SCOREprime=[];
    SVM='NormSVM_';
    for i=1:(length(dir(Path.NormSpeak))-2)
        SVMnew=[SVM,num2str(i),'.libsvm'];
        dos(['svm-predict.exe  -b 1 SVM_test.txt  ',SVMnew,'  SVM-test-OUT.txt']);
        [A,B1,B2]= textread('SVM-test-OUT.txt','%s %f %f');
        if B1(1)==1
            B1(1)=[]; B2(1)=[];
            SCOREnorm=[SCOREnorm;B1'];
        else
            B1(1)=[]; B2(1)=[];
            SCOREnorm=[SCOREnorm;B2'];
        end
    end
    %----
    for n1=1:size(SCORE,2)
        for n2=1:size(SCORE,1)
            SCOREprime(n2,n1)=log(SCORE(n2,n1)/(SCORE(n2,n1)+sum(SCOREnorm(:,n1))));
        end
    end
    %----
    SCORE=SCOREprime;
else
    
    if isempty(MatlabSVM_train)
        if NormScrs_target==1
            SCORE=ApplyLLR2(SCORE);
        else
            SCORE=ApplyLLR(SCORE);
        end
    else
        C=-0.5;
        SCORE=logsig(C*SCORE);
        SCORE=ApplyLLR2(SCORE);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




