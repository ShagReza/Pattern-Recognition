function [MSV,CSV,W]=readALZgmmInv(filename)
% MSV=readALZgmm(filename)
% [MSV,CSV,W]=readALZgmm(filename)
%
%        filenmame : an ALIZE GMM in raw format with C components and
%        feature oder F
%  output:
%        MSV: a C*F large mean SuperVector
%        CSV: a C*F large covariance SuperVector
%        W: a C large weight SuperVector
%
 fid = fopen(filename); 
 C=fread(fid,1,'uint32');
 F=fread(fid,1,'uint32');
%  disp([ 'Nb Gauss: [' num2str(C) '] Feat Order:[' num2str(F) '] SV:[' num2str(F*C) ']' ]);
 MSV=[];CSV=[];
 W=fread(fid,C,'double');%weight
 for Ic=1:C
     Ct=fread(fid,1,'double');%cst
     Dt=fread(fid,1,'double');%det
     Ch=fread(fid,1,'char');%char
     Cv=fread(fid,F,'double');%cov (inverse)
     CSV=[CSV;Cv];
     Mn=fread(fid,F,'double');%mean
     MSV=[MSV ;Mn]; 
 end   
 
 fclose(fid);
end
