

function FeatureLabelExtraction_ivectorTest(pathstates,new)

load( [pathstates,'\Methods'] );
load( [pathstates,'\Path']);
load( [pathstates,'\Param'] );EnhSegmentsPath   = dir([new,'\Waves\*.wav']);


WavPath   = dir([new,'\Waves\*.wav']);
for b1 = 1:length(EnhSegmentsPath)
    b1
    InputWaveFile=[new,'\Waves\',WavPath(b1).name];
    name=WavPath(b1).name; name(end-3:end)=[];
    OutputLabelFile=[new,'\Labels\',name,'.lbl'];
    OutputFeatureFile=[new,'\Features\',name,'.ftr'];
    dos(['VAD.exe ',InputWaveFile,'  ',OutputLabelFile,' 5 10 10  0  SNR.txt 0.03 ']);
    %dos(['MFCCWhitSAD.exe ',InputWaveFile,' ',OutputFeatureFile ,' ',Path.SADmodels]);
    dos(['MFCC.exe ',InputWaveFile,' ',OutputFeatureFile]);
end
%-------------------------------------------
