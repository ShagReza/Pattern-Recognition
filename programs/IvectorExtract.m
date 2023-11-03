
function [LDAmodel,P_NAP,B_WCCN]=IvectorExtract(pathstates,IvectorSvmpath,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,NAPivector_Dim,c,g,SVM_Matlab,kerneltype,ny,TrainMethod)
%------------------------------------------------------------------
load(pathstates);
load([pathstates,'\train']);
LDAmodel=[];P_NAP=[];B_WCCN=[];
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
fid_List = fopen([JFA_s_lists  'FA-ivector'  ,'.lst'],'w');
Label1 ='MIX04_';
Label2 ='_f=';
Label3 ='data/Features/';
NumLan=Train.NumSpeaker;
class=Train.class-1;
k=0;
for i=1:length(Train.class)
    k=k+1;
    FtName=Train.name{i}; 
    VV = readHTK([IvectorSvmpath,'\Features\',FtName,'.ftr'],0);
    save ([Path.Prog,'\data\Features\', FtName,'.ascii'],'VV','-ASCII');
    Label4=Train.classname{i};
    fprintf(fid_List,'%s\n' ,[Label1 Label4  Label2 Label3 FtName]);
end
fclose all;

%Baum Weltch:
if (TrainMethod==1)
    make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],'FA-ivector');
elseif (TrainMethod==2)
    make_suf_stat_enroll_ivector('FA-ivector');
end
%--------------------------------------------------------------------------
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

%---
load(['optimum_output/' ['v_opt_' num2str(10) ]], 'v');
%---
if (TrainMethod==1)
    [y]=estimate_y_and_v(F, N, S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
elseif (TrainMethod==2)
    [y]=estimate_y_and_v_ivector(S, m, E, 0, v, 0, zeros(n_speakers,1), 0, zeros(n_sessions,1), spk_ids);
end
%--------------------------------------------------------------------------
%normalizing ivector for cosine kernel:
if (Norm_ivector==1)
    for i=1:size(y,1)
        y(i,:)=y(i,:)./norm(y(i,:));
    end
end
%---
%LDA:
if (LDA_ivector==1)
    LDA_Struct = struct('X', y', 'y', class+1);
    reg=0.001;
    LDAmodel = lda_reg_me ( LDA_Struct ,  NumLan-1 , reg );
    y=linproj(y', LDAmodel)';
end
%---
%NAP:
if (NAP_ivector==1)
    NAP_Struct = struct('X', y', 'y', class+1);
    WCC = WithenClassCov(NAP_Struct);
    [Vec,D] = eig (WCC);
    [D,inx] = sort(diag(D),1,'descend');
    V = Vec(:,inx(1:NAPivector_Dim));
    P_NAP=eye(size(y,2))-V*V';
    y=(P_NAP*y')';
end
%---
%WCCN:
if (WCCN_ivector==1)
    NAP_Struct = struct('X', y', 'y', class+1);
    WCC = WithenClassCov(NAP_Struct);
    reg=0.001;
    B_WCCN=chol(inv(WCC+ reg * eye(size(WCC,1))));
    y=(B_WCCN*y')';
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%Grid_Py(y,class,Path.Prog,'train');
MatlabSVM_train=OneVersusRest_SVM(y,class,Path.Prog,c,g,SVM_Matlab,kerneltype,'train');
%--------------------------------------------------------------------------
