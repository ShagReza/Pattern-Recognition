

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test:
function [ivector_test,Numfiles_test,NumSpks_test,NumSegs_test]=TestIvector2_realdata(pathstates,IvectorSvmpath,JFA_eigen_lists)
iter=10;
load(pathstates);
NumOfSegments=[]; %number of segments
FS=8000;
%________________
task='test';
FaSvmpath=IvectorSvmpath;
new=[IvectorSvmpath,'\',task];
mkdir(new);
mkdir([new,'\Diarization\']);
mkdir([new,'\Waves'          ]);
mkdir([new,'\EnhancedWaves'  ]);
mkdir([new,'\Models']);
mkdir([new,'\Features']);
mkdir([new,'\Labels']);
%________________
PathModels=[IvectorSvmpath,'\Models'];
copyfile([PathModels,'\UBM.gmm'],[FaSvmpath,'\',task,'\Models\UBM.gmm'])
copyfile([PathModels,'\UBMinit.gmm'],[FaSvmpath,'\',task,'\Models\UBMinit.gmm'])
[MSV,CSV,W] = readALZgmm([PathModels,'\UBM.gmm']);
%________________
ivector_test=[];
TargetSpeakers=dir(Path.TargetSpeakers_Test);
for nl = 3:length(TargetSpeakers)
    PathWaves  = dir([Path.TargetSpeakers_Test,'\',TargetSpeakers(nl).name, '\*.wav']); % waves path of language nl
    Numfiles_test(nl-2)=length(PathWaves);
    for j = 1:length(PathWaves)
        nl
        rmdir([new,'\Waves\'          ],'s'); mkdir([new,'\Waves\'          ]);
        rmdir([new,'\EnhancedWaves\'  ],'s'); mkdir([new,'\EnhancedWaves\'  ]);
        rmdir([new,'\Features\'       ],'s'); mkdir([new,'\Features\'       ]);
        rmdir([new,'\Labels\'       ],'s'); mkdir([new,'\Labels\'       ]);
        rmdir([new,'\Diarization '],'s'); mkdir([new,'\Diarization\']);
        
        TestPath = [Path.TargetSpeakers_Test,'\',TargetSpeakers(nl).name, '\',PathWaves(j,1).name];
        
        %Diarization&SAD:
        
        dos(['SADLibTest.exe -Diarization ',TestPath,' ', [new,'\Diarization\'],' 0']); %???????????
        %dos(['SpeakerDiarization.exe ',PathWaves(j,1).name,[' ',Path.TargetSpeakers_Test,'\',TargetSpeakers(nl).name, '\ '] ,[new,'\Diarization\'],'  1   0 ']);
        %dos(['SpeakerDiarizationTemp_89_6-final.exe ',ImpSpeakers(nl).name,[' ',Path.Impostors_Test,'\ '],[new,'\Diarization\'],'  1   0 ']);
        
        filename=PathWaves(j,1).name; filename(end-3:end)=[];filename=[filename,'_List.txt'];
        SpkNames=textread([new,'\Diarization\',filename],'%s');
        
        NumSpks_test(nl-2,j)=length(SpkNames);
        for i=1:length(SpkNames)
            name=SpkNames{i,1}; name(end-3:end)=[];  SpkNames{i,1}=name;
            InputWaveFile=[new,'\Diarization\',SpkNames{i,1},'.wav'];
            OutputLabelFile=[new,'\Diarization\',SpkNames{i,1},'.lbl'];
            
            % if no wave file made after diarization
            existFlag= exist(InputWaveFile); NS=0;
            
            if existFlag==2
                % limit length of file
                % SAD error: Number of Frames > MAX_T
                [s,fs]=wavread(InputWaveFile);
                if length(s)>fs*600 %10min
                    s(fs*600:end)=[];
                end
                wavwrite(s,fs,InputWaveFile);
                %
                
                dos(['SADLibTest.exe -SAD ',InputWaveFile,' ', OutputLabelFile,' ', Path.SADmodels,'   Temp 1 Energy.txt 0  10  10 0.05 0.73 100']);
                %dos(['VAD.exe ',InputWaveFile,' ',OutputLabelFile,' 5 10 10  0  SNR.txt 0.03 ']);
                
                dos(['Clip-VOICE.exe ' , InputWaveFile,' ',OutputLabelFile, ' ', 'a.wav']);
                InputWaveFile='a.wav';
                AA=0; BB=0;
                [AA,BB,CC] = textread(OutputLabelFile,'%f %f %s');
                if sum(BB-AA)>5 %5 second
                    [I, NS]=Segmentation_Gsl(1,Param.SegLen,FS,Param.LapLen,InputWaveFile,new,name);
                else
                    NS=0;
                end
            end
            NumSegs_test(nl-2,j,i)=NS;
        end
        
        FeatureLabelExtraction_ivectorTest2(pathstates,new);
        %------
        JFA_s_lists       =[Path.Prog,'\lists\'];    mkdir(JFA_s_lists);
        fid_List = fopen([JFA_s_lists  JFA_eigen_lists  ,'.lst'],'w');
        Label1 ='MIX04_';
        Label2 ='_f=';
        Label3 ='data/Features/';
        
        dirFiles=dir([new,'\Labels\'       ]);
        for jj=3:length(dirFiles)
            dirFiles(jj).name(end-3:end)=[];
            VV = readHTK([new,'\Features\', dirFiles(jj).name,'.ftr'],0);
            save (['data\Features\', dirFiles(jj).name,'.ascii'],'VV','-ASCII');
            fprintf(fid_List,'%s\n' ,[Label1 TargetSpeakers(nl).name  Label2 Label3 dirFiles(jj).name]);
        end
        fclose (fid_List);
        make_suf_stat_enroll(Path.Prog,[Path.Prog,'\data\Features\'],JFA_eigen_lists);
        
        tst=load(['data/stats/' JFA_eigen_lists]);
        m             = load('models/ubm_means');
        E             = load('models/ubm_variances');
        v_matrix_file = ['optimum_output/' ['v_opt_' num2str(iter) ]];
        load(v_matrix_file);
        ny = size(v, 1);
        tst.spk_ids = (1:size(tst.N,1))';
        n_speakers=max(tst.spk_ids);
        n_sessions=size(tst.spk_ids,1);
        
        tst.y=zeros(n_speakers,ny);
        tst.z=zeros(n_speakers,size(tst.F,2));
        [tst.y]=estimate_y_and_v(tst.F, tst.N, 0, m, E, 0, v, 0, tst.z, tst.y, zeros(n_sessions,1), tst.spk_ids);
        %---
        ivector_test=[ivector_test;tst.y];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






