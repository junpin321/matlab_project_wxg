function y=gwmprocess(ElapseTime,FNAME,nlay,ncol,nrow)
%% Read and Output Groundwater Model Simulation Binary File /.UCN//.HEAD/

%% PostProcess Model Results
fid=fopen(FNAME,'r');
while ~feof(fid)
    y=zeros(ncol,nrow,nlay);
    for k=1:nlay
        % ITMP1, ITMP2, ITMP3 - Transport Step, Time Step, Stress Period
        % NTRANS,KSTP,KPER
        fread(fid, 3,'ubit32');
        fseek(fid,0,'cof');
        % Total Elapsed Time - TIME0
        TIME0 = fread(fid, 1,'float');
        % Skip 'CONCENTRATION' character length=16
        fseek(fid,16,'cof');
        % NC,NR,ILAY - Ncol,Nrow,Nlay
        fread(fid, 3,'ubit32');
        y(:,:,k)=fread(fid,[ncol,nrow],'real*4');
    end
    if ElapseTime==TIME0 
        break;
    end
end
fclose(fid);
return

end

