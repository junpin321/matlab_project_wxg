function popcons = gwmodel(pwell)
% Running groundwater model
% Output Groundwater flow field
% pwell -- Million Liter /yr  // ML/yr == 10^3 m3/yr
% pwell=opt.pop(locV,:);  
DV=size(pwell,2);

% Pumping Rate // Monthly Share Coefficient
% 7,8,9,10,11,12,1,2,3,4,5,6
% Jul, Aug, Sep, Oct, Nov, Dec, Jan, Feb, Mar, Apr, May, Jun
MSCoeff=[6.70,7.23,6.79,10.31,7.74,9.36,14.21,8.63,7.10,7.71,7.64,6.58].*0.01;
MonthLength=repmat([31,31,30,31,30,31,31,28,31,30,31,30],DV,1);

% Allocate Total pumping rate per year TO per month -- m3/day
PumpRate=(repmat(pwell',1,12).*repmat(MSCoeff,DV,1)./MonthLength).*1000;

% Nsel,3 -- Layer Row Column  --- Well Location  
% PW1-PW3 // PW4-PW6 // PW7-PW12, PW14-PW17 // PW19-PW22
Wellloc=[5,216,58;5,213,59;5,218,54;...
    3,168,87;3,166,85;5,164,84;...
    5,29,100;3,18,99;1,17,97;1,16,98;5,20,102;3,21,102;...
    3,29,105;5,20,100;5,20,98;3,21,99;...
    5,118,74;5,123,73;5,128,73;5,133,73];

%% Replace MODFLOW .wel input file for updating decision variables
fid=fopen('Macleay.wel','r+');
% Move the file position marker to the correct line
format1='%10d%10d\n';
fprintf(fid,format1,[20,54]);
% For each Stress Period --- LAY ROW COL Pumping Rate
format2='%10d%10d%10d%10.3e\n';
for i=1:12
    fprintf(fid,format1,[20,0]);
    pumpwell=zeros(DV,4);
    pumpwell(:,1:3)=Wellloc;
    pumpwell(:,4)=PumpRate(:,i).*-1.0;
    for j=1:DV
        fprintf(fid,format2,pumpwell(j,:));
    end
end
fclose(fid);

%% Running MODFLOW2005 with content of .nam file as inputs                             
mydir = which('mf2005.exe') ;
command=[mydir,' Macleay.nam'];
system(command); 

%% Postprocessing .hds and .ucn files / Outputing concentration or head array
% Specify Elapsed Time --   One year // every month
ElapseTime=[31;62;92;123;153;184;215;243;274;304;335;365];
% NLAY NROW NCOL  
nlay=5; nrow=321; ncol=132;
FNAME1='Macleay.hds';
FNAME2='Macleay.ddn';
% Drawdown1 -- Drawdown2 -- Min KINC Head 
% -- Dryout Indicator -- Total Pumping Rate
popcons=zeros(1,8);

Draw=zeros(1,12);
Draw_Bore=zeros(1,12);
HeadMin=zeros(1,12);

% Only considering top layer
Layer=1;

% Outputing drawdown and head for every stress period
for i=1:12
    
    headf=gwmprocess(ElapseTime(i),FNAME1,nlay,ncol,nrow);
    drawd=gwmprocess(ElapseTime(i),FNAME2,nlay,ncol,nrow);
    
    % Dry Cell Indicator
    [rowm,~,~]=find(drawd(:,:,Layer)==-999.0);
    if ~isempty(rowm)
        popcons(1,4)=1;
    end
    
    % Head constraint zone //  
    % Drawdown < 2.0 && The top layer should not dry out
    DMCRE_Bore=max(max(drawd(52:61,211:220,Layer)));
    DHARH_Bore=max(max(drawd(82:90,162:170,Layer)));
    DSWRO_Bore=max(max(drawd(95:107,14:31,Layer)));
    Draw(i)=max([DMCRE_Bore,DHARH_Bore,DSWRO_Bore]);
    
    
    % Head>0.0 && Drawdown<1.0 && The top layer should not dry out
    HKINC_Bore=headf(68:87,112:138,Layer);
    DKINC_Bore=drawd(68:87,112:138,Layer);
    [row,col,~]=find(HKINC_Bore==-999.0);
    if ~isempty(row)
        HKINC_Bore(row(:),col(:))=999.0;
    end
    
    HeadMin(i)=min(min(HKINC_Bore));
    Draw_Bore(i)=max(max(DKINC_Bore));
    
end

% Drawdown and head constraint
popcons(1,1)=max(Draw);
popcons(1,2)=max(Draw_Bore);
popcons(1,3)=min(HeadMin);

% Total pumping rate constraint
popcons(1,5)=sum(pwell(1:3)); % Maguires Borefield
popcons(1,6)=sum(pwell(4:6)); % Hat Head Borefield
popcons(1,7)=sum(pwell(7:16)); % South West Rocks Borefield
popcons(1,8)=sum(pwell(17:20)); % Kinchela Borefield

return

end







