
%----------------------------------------------
function FeatureLabelExtraction_ivector(pathstates,IvectorSvmpath,segmentation_train)

load( [pathstates,'\Methods'] );
load( [pathstates,'\Path']);
load( [pathstates,'\Param'] );
task=IvectorSvmpath;
mkdir(task);
mkdir([task,'\Models'          ]);
mkdir([task,'\EnhancedWaves'  ]);
mkdir([task,'\Features'       ]);
mkdir([task,'\Labels'         ]);
mkdir([task,'\Waves'          ]);
mkdir([task,'\Test'          ]);
%--------
PathWaves  = dir([Path.UBM, '\*.wav']);
for nt = 1:length(PathWaves)
    TestPath = [Path.UBM, '\',PathWaves(nt,1).name];
    TestName    = [task,'\Waves\',PathWaves(nt,1).name];
    copyfile(TestPath,TestName);
end
%--------
W=30*8000;
OverW=15*8000;
LanFolders=dir(Path.TargetSpeakers_Train);
NL=length(LanFolders)-2;

Train=[]; k=0;
for nl = 1:NL
    LAN  = char(LanFolders(nl+2).name); % language nl
    PathWaves  = dir([Path.TargetSpeakers_Train,'\',LAN, '\*.wav']);
    NumOfTest(nl) = length(PathWaves); % number of wave files in language nl folder
    for nt = 1:NumOfTest(nl)
        TestPath = [Path.TargetSpeakers_Train,'\',LAN, '\',PathWaves(nt,1).name];
        TestName    = [task,'\Waves\',PathWaves(nt,1).name];
        if segmentation_train==0
            copyfile(TestPath,TestName);
        else
            [xx,fs] = wavread(TestPath);
            s = 0.99* resample(xx,8000,fs);
            i = 0;
            while length(s)>=(W)
                s1 = s(1:W);
                s(1:W-OverW) = [];
                i  = i+1;
                Name=PathWaves(nt,1).name; Name(end-3:end)=[];
                TestName    = [task,'\Waves\',Name,'_',num2str(i),'.wav'];
                wavwrite(s1,8000,TestName);
                k=k+1;
                Train.class(k)=nl;
                Train.name{k}=[Name,'_',num2str(i)];
                Train.classname{k}=LAN;
            end 
            if length(s)<W && length(s)>1600
                s1 = s;
                i  = i+1;
                TestName    = [task,'\Waves\',Name,'_',num2str(i),'.wav'];
                wavwrite(s1,8000,TestName);
                k=k+1;
                Train.class(k)=nl;
                Train.name{k}=[Name,'_',num2str(i)];
                Train.classname{k}=LAN;
            end
        end
    end
end
Train.NumSpeaker=NL;
save( [Path.stats,'train'], 'Train');
%-------
%Enhancement (task,Enh);
%--------
ft_func     = ['function_',Methods.ft];
ftsel_func  = ['function_',Methods.ftsel];
lab_func    = ['function_',Methods.lab,'2'];
%--------
WavPath   = dir([task,'\Waves\*.wav']);
for b1=1:length(WavPath)
    speech=[task,'\Waves\',WavPath(b1).name];
    dos(['VAD.exe ',speech,' lbl.lbl',' 5 10 10  0  SNR.txt 0.03 ']);
    dos(['Clip-VOICE.exe ' , speech,' lbl.lbl', ' ', 'a.wav']);
    dos(['Add-Noise.exe ' , 'a.wav',' ', speech, ' ','0.32767']);
    pathwav=[task,'\Waves\'];
    pathfeat=[task,'\Features\'];
    pathLabel=[task,'\Labels\'];
    Name=WavPath(b1).name; Name(end-3:end)=[];
    eval([ft_func,'(Name,pathwav,pathfeat)']);
    eval([lab_func,'(Name,pathwav,pathLabel)']);
    [Masking, FeatSize ] = eval(ftsel_func);
end
rmdir([task,'\Waves'          ],'s');
%-------------------------------------------

