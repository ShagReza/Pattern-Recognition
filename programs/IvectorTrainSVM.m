
function IvectorTrainSVM(yUBM,pathstates,IvectorSvmpath,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN,c,g,kerneltype,TrainMethod,NumImpSpeak)
%------------------------------------------------------------------
load(pathstates);
load([pathstates,'\train']);
mkdir([Path.Prog,'\models']);
mkdir([Path.Prog,'\data']);
mkdir([Path.Prog,'\data\Features']);
JFA_s_exp         =[Path.Prog,'\exp\'];            mkdir(JFA_s_exp);
JFA_s_lists       =[Path.Prog,'\lists\'];          mkdir(JFA_s_lists);
JFA_s_output      =[Path.Prog,'\optimum_output\']; mkdir(JFA_s_output);
JFA_s_stats       =[Path.Prog,'\data\stats\'];     mkdir(JFA_s_stats);
[MSV,CSV,W]=readALZgmm_FA([IvectorSvmpath,'\Models\UBM.gmm']);
save ([Path.Prog,'\models\ubm_means'],'MSV','-ASCII');
save ([Path.Prog,'\models\ubm_variances'],'CSV','-ASCII');
save ([Path.Prog,'\models\ubm_weights'],'W','-ASCII');
%--------------------------------------------------------------------------
Label1 ='MIX04_';
Label2 ='_f=';
Label3 ='data/Features/';
dirTargets=dir(Path.TargetSpeakers_Train);
for NS=1:Train.NumSpeaker
    y=[];
    k=0;
    %----------
    fid_List = fopen([JFA_s_lists  'FA-ivector'  ,'.lst'],'w');
    for j=1:length(Train.class)
        if Train.class(j)==NS
            k=k+1;
            VV = readHTK([IvectorSvmpath,'\Features\',Train.name{j},'.ftr'],0);
            save ([Path.Prog,'\data\Features\', Train.name{j},'.ascii'],'VV','-ASCII');
            Label4=Train.classname{j};
            fprintf(fid_List,'%s\n' ,[Label1 Label4  Label2 Label3 Train.name{j}]);
            SpeakerName=Train.classname{j};
            classSVM(k)=1;
        end
    end
    fclose all;
    %----------
    if (TrainMethod==1)
        make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],'FA-ivector');
    elseif (TrainMethod==2)
        make_suf_stat_enroll_ivector('FA-ivector');
    end
    %----------
    if (TrainMethod==1)
        train_mat_file = ['./data/stats/' 'FA-ivector'];
        load(train_mat_file); %loads F, N, spk_ids
    elseif (TrainMethod==2)
        S1=load('data/stats/1.mat');
        F=S1.Fi';
        N=S1.Ni';
    end
    m = load(['models/ubm_means'], '-ascii');
    E = load(['models/ubm_variances'], '-ascii');
    spk_ids=(1:k)';
    n_speakers=max(spk_ids);
    n_sessions=size(spk_ids,1);
    S = [];
    %----------
    load(['optimum_output/' ['v_opt_' num2str(10) ]], 'v');
    if (TrainMethod==1)
        [y]=estimate_y_and_v(F, N, S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
    elseif (TrainMethod==2)
        [y]=estimate_y_and_v_ivector(S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
    end
    %----------
    % non target data for SVM: ALL UBM data
    % y=[y;yUBM];
    % classSVM(k+1:k+size(yUBM,1))=0;
    %----------
    ymean=mean(y);
    for j=1:size(yUBM,1)
        SCORE(j)=(ymean*yUBM(j,:)')/(norm(ymean)*norm(yUBM(j,:)));
    end
    [a,b]=sort(SCORE,'descend');
    index_norm(1:NumImpSpeak)=b(1:NumImpSpeak);
    y_nontarget=[];
    for j=1:NumImpSpeak
        y_nontarget(j,:)=yUBM(index_norm(j),:);
    end
    y=[y;y_nontarget];
    classSVM(k+1:k+NumImpSpeak)=0;
    %----------
    if (Norm_ivector==1)
        for i=1:size(y,1)
            y(i,:)=y(i,:)./norm(y(i,:));
        end
    end
    %---
    %LDA:
    if (LDA_ivector==1)
        y=linproj(y', LDAmodel)';
    end
    %---
    %NAP:
    if (NAP_ivector==1)
        y=(P_NAP*y')';
    end
    %---
    %WCCN:
    if (WCCN_ivector==1)
        y=(B_WCCN*y')';
    end
    %Train SVM
    DatFile_SVM(y,classSVM,Path.Prog,'train');
    SVMnew=['LibSVM_train',num2str(NS),'.libsvm'];
    if (kerneltype=='2')
        dos(['svm-train.exe   -b 1  -s 0  -t 2 -c ', num2str(c),'  -g ', num2str(g),' SVM_train.txt  ',SVMnew]);
    elseif (kerneltype=='1')
        dos(['svm-train.exe   -b 1  -s 0  -t 0 -c ', num2str(c),' SVM_train.txt  ',SVMnew]);
    end
    
end
%--------------------------------------------------------------------------
