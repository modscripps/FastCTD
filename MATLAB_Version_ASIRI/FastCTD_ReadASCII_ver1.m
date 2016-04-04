function [FCTD] = FastCTD_ReadASCII_ver1(fname)
% function FCTD = FastCTD_ReadASCII(fname)
%
%   FastCTD_ReadASCII(FNAME) read data from OPG Fast CTD ASCII file format
%   and returns a FastCTD structure.
%   The FastCTD structure contains details recorded in the file
%   The FastCTD file structure is as follow
%   
%   FCTD: [struct]
%         header: [struct]
%           time: [Nx1 double]
%%%%      ctd_ASCII: [Nx22 char]
%%%%      mcr_ASCII: [Nx40 char]
%%%%      acc_ASCII: [Nx12 char]
%    temperature: [Nx1 double] Temperature
%       pressure: [Nx1 double] Pressure
%   conductivity: [Nx1 double] Conductivity
%  uConductivity: [Nx10 double] Micro Conductivity Data
%   acceleration: [Nx3 double]
%            GPS: [struct]
%          winch: [struct]
%
% Written by Jody Klymak
% Updated 2011 06 21 by San Nguyen


FID = fopen(fname,'r');
if FID<0
    error('MATLAB:FastCTD_ReadASCII:FileError', 'Could not open file %s',fname);
end;


FCTD=FastCTD_ASCII_parseheader(FID);

%convert time to MATLAB time
if FCTD.header.offset_time < 0
    FCTD.header.offset_time = -FCTD.header.offset_time/86400+datenum(1970,1,1);
else
    FCTD.header.offset_time = FCTD.header.offset_time/86400+datenum(1970,1,1);
end
if FCTD.header.system_time < 0
    FCTD.header.system_time = -FCTD.header.system_time/86400/100+FCTD.header.offset_time;
else
    FCTD.header.system_time = FCTD.header.system_time/86400/100+FCTD.header.offset_time;
end

fclose(FID);

% extract OPGCTD stuff...
unix(['grep OPGCTD  ' fname ' > tmp.ctd.txt']);

% fix negative time stamps that joyously occur in the data set.
% FCTDFixCtdTmp;

FID=fopen('tmp.ctd.txt','r');
% extract fields of interest...

ctdlen=22;
mcrlen=40;
acclen=12;

ff = fread(FID,'*char');
fclose(FID);
if isempty(ff)
    FCTD=[];
    return;
end;

% strip any minus signs.  Times will be wrong
% this is just in case if the time was recorded with a minus sign
bad = (ff=='-');
ff(bad) =[];

% in = strfind(ff','$OPGCTD');
in = regexpi(ff','\$+\O+\P+\G+\C+\T+\D');
linel = median(diff(in));
in = in-11;

s = char(zeros(length(in),linel+1));
for i=1:length(in);
    if in(i)+linel-1<length(ff);
        s(i,:)=[ff(in(i)+(0:(linel-1))); char(10)];
    else
        s(i,:)=[];
    end;
end;


s2 = cat(2,s(:,1:11),char(10*ones(size(s,1),1)))';
data = textscan(s2(:),'%f');
t = data{1};

%t=str2num(s(:,2:11));

FCTD.time = t/100/24/3600+ FCTD.header.offset_time;
% idpos = strfind(s(1,:),'$OPGCTD');
idpos = 12;
ctdpos = idpos+7;
FCTD.ctd_ASCII = s(:,ctdpos+(1:ctdlen)-1);

% somehow bad stuff gets in here (non-hex??);
bad = ~ismember(FCTD.ctd_ASCII,['0':'9' 'A':'F']);
FCTD.ctd_ASCII(bad) = '0';



if linel>=ctdpos+ctdlen+mcrlen
    FCTD.mcr_ASCII = s(:,ctdpos+ctdlen+(1:mcrlen)-1);
    if linel>=ctdpos+ctdlen+mcrlen+acclen
        FCTD.acc_ASCII = s(:,ctdpos+ctdlen+mcrlen+(1:acclen)-1);
    end;
end;

% Get engineering units...
if isfield(FCTD,'ctd_ASCII');
    FCTD = FastCTD_ASCII_getTemp(FCTD);
    FCTD = FastCTD_ASCII_getPres(FCTD);
    FCTD = FastCTD_ASCII_getCond(FCTD);
    FCTD = rmfield(FCTD,'ctd_ASCII');
end;

if isfield(FCTD,'mcr_ASCII');
    FCTD = FastCTD_ASCII_getMcr(FCTD);
    FCTD = rmfield(FCTD,'mcr_ASCII');
end;

if isfield(FCTD,'acc_ASCII');
    FCTD = FastCTD_ASCII_getAcc(FCTD);
    FCTD = rmfield(FCTD,'acc_ASCII');
end;

% Extract GPS stuff
unix(['grep GPGGA  ' fname ' > tmp.gps.txt']);
% local function...
FCTD.GPS = FastCTD_ASCII_readGPS('tmp.gps.txt',FCTD);

% Extract Winch stuff
unix(['egrep ^T.{10}[$]OPGWST.{55}$  ' fname ' > tmp.winch.txt']);
FCTD.winch = FastCTD_ASCII_readWinch('tmp.winch.txt',FCTD);

delete('tmp.*.txt');

return;
end

%  reads the Acceleration
function FCTD = FastCTD_ASCII_getAcc(FCTD)

m = reshape(FCTD.acc_ASCII',4,[])';
mm = hex2dec_(m);

FCTD.acceleration = reshape(mm,3,[])';

return
end

%  reads the Micro Conductivity data
function FCTD = FastCTD_ASCII_getMcr(FCTD)

m = reshape(FCTD.mcr_ASCII',4,[])';
mm = hex2dec_(m);

FCTD.uConductivity = reshape(mm,10,[])';
end

%  reads and apply calibration to the temperature data
function FCTD = FastCTD_ASCII_getTemp(FCTD)

a0 = FCTD.header.ta0;
a1 = FCTD.header.ta1;
a2 = FCTD.header.ta2;
a3 = FCTD.header.ta3;

rawT = hex2dec_(FCTD.ctd_ASCII(:,1:6));
mv = (rawT-524288)/1.6e7;
r = (mv*2.295e10 + 9.216e8)./(6.144e4-mv*5.3e5);
FCTD.temperature = a0+a1*log(r)+a2*log(r).^2+a3*log(r).^3;
FCTD.temperature = 1./FCTD.temperature - 273.15;
return;
end

%  reads and apply calibration to the conductivity data
function FCTD = FastCTD_ASCII_getCond(FCTD)

g = FCTD.header.cg;
h = FCTD.header.ch;
i = FCTD.header.ci;
j = FCTD.header.cj;
tcor = FCTD.header.ctcor;
pcor = FCTD.header.cpcor;

f = hex2dec_(FCTD.ctd_ASCII(:,(1:6)+6))/256/1000;

FCTD.conductivity = (g+h*f.^2+i*f.^3+j*f.^4)./(1+tcor*FCTD.temperature+pcor*FCTD.pressure);

return;
end

%  reads and apply calibration to the pressure data
function FCTD = FastCTD_ASCII_getPres(FCTD)

pa0 = FCTD.header.pa0;
pa1 = FCTD.header.pa1;
pa2 = FCTD.header.pa2;
ptempa0 = FCTD.header.ptempa0;
ptempa1 = FCTD.header.ptempa1;
ptempa2 = FCTD.header.ptempa2;
ptca0 = FCTD.header.ptca0;
ptca1 = FCTD.header.ptca1;
ptca2 = FCTD.header.ptca2;
ptcb0 = FCTD.header.ptcb0;
ptcb1 = FCTD.header.ptcb1;
ptcb2 = FCTD.header.ptcb2;

rawP = hex2dec_(FCTD.ctd_ASCII(:,(1:6)+12));

y = hex2dec_(FCTD.ctd_ASCII(:,(1:4)+18))/13107;

t = ptempa0+ptempa1*y+ptempa2*y.^2;
x = rawP-ptca0-ptca1*t-ptca2*t.^2;
n = x*ptcb0./(ptcb0+ptcb1*t+ptcb2*t.^2);

FCTD.pressure = (pa0+pa1*n+pa2*n.^2-14.7)*0.689476;

return;
end

%  parse all the lines in the header of the file
function FCTD = FastCTD_ASCII_parseheader(FID)

fgetl(FID);
s=fgetl(FID);
[v,val]=FastCTD_ASCII_parseheadline(s);
eval(['FCTD.header.' lower(v) '=' val ';']);
s=fgetl(FID);
while ~strncmp(s,'%*****END_FCTD',14) && ~feof(FID)
    [v,val]=FastCTD_ASCII_parseheadline(s);
    if ~isempty(v)
        try
            eval(['FCTD.header.' lower(v) '=' val ';']);
        catch obj
            if strncmp(v,'FCTD_VER',8)
                eval(['FCTD.header.' lower(v) '=''' val ''';']);
            else
                disp(obj.message);
                disp(['Error occured in string: ' disp(s);]);
            end
            
        end;
    end;
    s=fgetl(FID);
    strncmp(s,'%*****END_FCTD',14);
end;
return;
end

%  parse each line in the header to detect comments
function [v,val]=FastCTD_ASCII_parseheadline(s)
if s(1)~='%'
    
    i = strfind(s,'=');
    v=s(1:i-1);
    val = s(i+1:end);
else
    v=[];
    val=[];
end;

return;
end


%  reading winch data
function winch=FastCTD_ASCII_readWinch(fname,FCTD)
fin = fopen(fname,'r');
s=fscanf(fin,'%c');
s=reshape(s,74,[])';
fclose(fin);

winch.payoutvel = str2num(s(:,44:49));
winch.payout = str2num(s(:,32:37));
winch.payoutAtm = str2num(s(:,24:30));
winch.current = str2num(s(:,51:57));
winch.time = str2num(s(:,2:11))/100/24/3600+ FCTD.header.offset_time;
winch.status = str2num(s(:,end-7:end-3));
return;
end

%  reading GPS data
function GPS = FastCTD_ASCII_readGPS(fname,FCTD)

FID = fopen(fname,'r');
%%%%%
frewind(FID);
str = fread(FID,'*char');
% divide into lines and look for lines with length around the size of 71
% char
ind = [0; find(str == 10); length(str)+2];
line_length = diff(ind)-1;
ind(1) = 1;
ind(end) = ind(end) - 1;

good_str = false(size(str));

for i = 1:length(line_length)
    if (line_length(i) <= 81)
        good_str(ind(i):ind(i+1)-1) = true;
    end
end

str = str(good_str);

data = textscan(str,'%*c%f%*s%f%f%s%f%s%*f%*f%*f%*f%*s%*s%*s%*s%*s','Delimiter',{'\n',',','$'});

GPS.time = data{1}/100/24/3600+FCTD.header.offset_time;

GPS.latitude = floor(data{3}/100) + mod(data{3},100)/60; % then add minutes
GPS.latitude = GPS.latitude.*(2*strcmpi(data{4},'N')-1); % check for north or south

GPS.longitude = floor(data{5}/100) + mod(data{5},100)/60; % then add minutes
GPS.longitude = GPS.longitude.*(2*strcmpi(data{6},'E')-1); % check for East or West (if west multiply by -1)

GPS.GPS_time = floor(data{2}/100/100)/24 + floor(mod(data{2}/100,100))/24/60 + mod(data{2},100)/24/3600 + floor(GPS.time);

% check for time wrap around
for num = 1:length(GPS.GPS_time)
    if GPS.GPS_time(num)-GPS.time(num) > .9;
        GPS.GPS_time(num)=GPS.GPS_time(num)-1;
    end
end


fclose(FID);

end

%  a secondary function to convert hex to dec but making sure the arguments
%  are correctly formated as hex
function d = hex2dec_(h)
h(~((h>='0' & h<='9')|(h>='A' & h<='F')))='0';
d = hex2dec(h);
return;
end