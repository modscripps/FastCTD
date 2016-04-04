function [FCTD] = FastCTD_ReadASCII(fname)
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
%           gyro: [Nx3 double]
%   acceleration: [Nx3 double]
%        compass: [Nx3 double]
%            GPS: [struct]
%          winch: [struct]
%
% Written by Jody Klymak
% Updated 2011 06 21 by San Nguyen
% Updated 2014 11 02 by San Nguyen % added altimeter time


FID = fopen(fname,'r');
if FID<0
    error('MATLAB:FastCTD_ReadASCII:FileError', 'Could not open file %s',fname);
end;


FCTD = FastCTD_ASCII_parseheader(FID);

%convert time to MATLAB time
if FCTD.header.offset_time < 0
    FCTD.header.offset_time = correctNegativeTime(FCTD.header.offset_time)/86400+datenum(1970,1,1);
else
    FCTD.header.offset_time = FCTD.header.offset_time/86400+datenum(1970,1,1);
end
if FCTD.header.system_time < 0
    FCTD.header.system_time = correctNegativeTime(FCTD.header.system_time)/86400/100+FCTD.header.offset_time;
else
    FCTD.header.system_time = FCTD.header.system_time/86400/100+FCTD.header.offset_time;
end

fclose(FID);

% extract OPGCTD stuff...
unix(['grep OPGCTD  ' fname ' > tmp.ctd.txt']);

% fix negative time stamps that joyously occur in the data set.
% FCTDFixCtdTmp;
try 
FID=fopen('tmp.ctd.txt','r');
% extract fields of interest...

ctdlen=22;
mcrlen=40;
acclen=36;
altlen=4;
cntlen=8;

ff = fread(FID,'*char');
fclose(FID);
catch err
    disp('Error in reading CTD data');
    disp(err);
    ff = [];
end
if isempty(ff)
    FCTD=[];
    return;
end;

% strip any minus signs.  Times will be wrong
% this is just in case if the time was recorded with a minus sign
% bad = (ff=='-');
% ff(bad) =[];

% search for position of time
% in = strfind(ff','$OPGCTD');
ff = ff';
in = regexpi(ff,'T+\d*+\$+O+P+G+C+T+D');
linel = 130;%median(diff(in));
% in = in-11;
ff1 = ff;
% in case we have error in the CTD data lines
ind = find(diff(in)~=linel);
if ~isempty(ind)
    new_indices = true(size(ff));
    wrong_indices1 = false(size(ff));
    wrong_indices2 = false(size(ff));
    for i = 1:numel(ind);
        if (in(ind(i)+1) - in(ind(i)))>130
            i1 = in(ind(i))+130;
            if ind(i)<numel(in)
                i2 = in(ind(i)+1)-1;
            else
                i2 = numel(in);
            end
%             disp('********************');
%             disp(ff(i1-130:i2+30));
        else
            i1 = in(ind(i));
            i2 = in(ind(i)+1)-1;
%             disp('#############################');
%             disp(ff(i1-130:i2+30));
        end
        wrong_indices1(i1-2) = true; % this is the in
        wrong_indices2(i1-1) = true; % this is the in
        new_indices(i1:i2) = false;
    end
    ff(wrong_indices1) = char(13);
    ff(wrong_indices2) = char(10);
    ff = ff(new_indices);
end

% % search for position of time
% in = find(strtrim(ff)==sprintf('\n'));
% linel = median(diff(in));

% s = char(zeros(length(in),linel+1));
% s = char(zeros(length(in),linel-1));
% for i=1:length(in);
%     if in(i)+linel-1<length(ff);
% %         s(i,:)=[ff(in(i)+(0:(linel-1))); char(10)];
%         s(i,:)=[ff(in(i)+(0:(linel-3))); char(10)];
%     else
%         s(i,:)=[];
%     end;
% end;
% keyboard;
s = reshape(ff,linel,[])';

time_ASCII = cat(2,s(:,2:11),char(10*ones(size(s,1),1)))';
if ~isempty(time_ASCII(:))
    data = textscan(time_ASCII(:),'%f');
    t = data{1};
else
    return;
end

FCTD.time = t/100/24/3600+ FCTD.header.offset_time;
idpos = 12;
ctdpos = idpos+7;
FCTD.ctd_ASCII = s(:,ctdpos+(1:ctdlen)-1);

% somehow bad stuff gets in here (non-hex??);
bad = ~ismember(FCTD.ctd_ASCII,['0':'9' 'A':'F']);
FCTD.ctd_ASCII(bad) = '0';



if linel>=ctdpos+ctdlen+mcrlen+cntlen
    FCTD.mcr_ASCII = s(:,ctdpos+ctdlen+(1:mcrlen)-1);
    if linel>=ctdpos+ctdlen+mcrlen+acclen+cntlen
        FCTD.YEI_ASCII = s(:,ctdpos+ctdlen+mcrlen+(1:acclen)-1);
        if linel>=ctdpos+ctdlen+mcrlen+acclen+altlen+cntlen
            FCTD.alti_ASCII = s(:,ctdpos+ctdlen+mcrlen+acclen+(1:altlen)-1);
        end
    end;
end;
% somehow bad stuff gets in here (non-hex??);
bad = ~ismember(FCTD.mcr_ASCII,['0':'9' 'A':'F']);
FCTD.mcr_ASCII(bad) = '0';
bad = ~ismember(FCTD.YEI_ASCII,['0':'9' 'A':'F']);
FCTD.YEI_ASCII(bad) = '0';
bad = ~ismember(FCTD.alti_ASCII,['0':'9' 'A':'F']);
FCTD.alti_ASCII(bad) = '0';

% Get engineering units...
if isfield(FCTD,'ctd_ASCII');
    if isempty(FCTD.ctd_ASCII)
        FCTD.temperature = [];
        FCTD.pressure = [];
        FCTD.conductivity = [];
    else
        FCTD = FastCTD_ASCII_getTemp(FCTD);
        FCTD = FastCTD_ASCII_getPres(FCTD);
        FCTD = FastCTD_ASCII_getCond(FCTD);
    end
    FCTD = rmfield(FCTD,'ctd_ASCII');
end;

if isfield(FCTD,'mcr_ASCII');
    if isempty(FCTD.mcr_ASCII)
        FCTD.uConductivity = ones(0,10);
    else
        FCTD = FastCTD_ASCII_getMcr(FCTD);
    end
    FCTD = rmfield(FCTD,'mcr_ASCII');
end;

if isfield(FCTD,'YEI_ASCII');
    if isempty(FCTD.YEI_ASCII)
        FCTD.gyro = ones(0,3);
        FCTD.acceleration = ones(0,3);
        FCTD.compass = ones(0,3);
    else
        FCTD = FastCTD_ASCII_getYEI(FCTD);
    end
    FCTD = rmfield(FCTD,'YEI_ASCII');
end;

if isfield(FCTD,'alti_ASCII');
    if isempty(FCTD.alti_ASCII)
        FCTD.altTime = NaN(0,1);
    else
        FCTD = FastCTD_ASCII_getAltimeter(FCTD);
    end
    FCTD = rmfield(FCTD,'alti_ASCII');
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

%  reads the altimeter
function FCTD = FastCTD_ASCII_getAltimeter(FCTD)

try
    m = reshape(FCTD.alti_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);

try
    % time is in count of 1/(40kHz)
    FCTD.altTime = mm/4.0e4;
catch
    FCTD.altTime = ones(0,1);
end


return;
end

%  reads the Acceleration
function FCTD = FastCTD_ASCII_getYEI(FCTD)
try
    m = reshape(FCTD.YEI_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);
mm(mm>=hex2dec('8000')) = -(2.^16-mm(mm>=hex2dec('8000')));

try
    tmp = reshape(mm,9,[])';
catch
    tmp = ones(0,9);
end
FCTD.gyro = tmp(:,1:3)*pi/180*0.07;
FCTD.acceleration = tmp(:,4:6)/16384;
FCTD.compass = tmp(:,7:9)/1090;

% From: Yost Engineering Support <support@yostengineering.com>
% Subject: 3-Space Calibration Algorithms
% Date: July 27, 2012 9:58:12 AM GMT-10:00
% To: mgoldin@ucsd.edu
% Reply-To: support@yostengineering.com
%
% Hello,
%
% Here is how we convert the raw data from our component sensors into usable data:
%
% Gyroscope:
% 1)We add the bias components(the last 3 components) of the gyroscope
%   calibration data(command 164) each onto their respective axis.
% 2)We multiply all axes by PI/180 to convert from degrees into radians.
% 3)Depending on the dps range, we multiply all axes by:
%    Range     Multiplier
%    250dps    .00875
%    500dps    .0175
%    2000dps   .07 (default range)
% 4)We multiply the matrix components(the first 9 components) of the gyroscope
%   calibration data with the gyroscope vector.
%
% Accelerometer:
% 1)We add the bias components(the last 3 components) of the accelerometer
%   calibration data(command 163) each onto their respective axis.
% 2)We divide all axes by 16384.
% 3)Depending on the g range, we multiply all axes by:
%    Range  Multiplier
%    2g     1 (default range)
%    4g     2
%    8g     4
% 4)We multiply the matrix components(the first 9 components) of the accelerometer
%   calibration data with the accelerometer vector.
%
% Compass:
% 1)We add the bias components(the last 3 components) of the compass calibration
%   data(command 162) each onto their respective axis.
% 2)Depending on the compass range, we divide all axes by:
%    Range      Divisor
%    0.88 Ga    1370
%    1.3 Ga     1090 (default range)
%    1.9 Ga     820
%    2.5 Ga     660
%    4.0 Ga     440
%    4.7 Ga     390
%    5.6 Ga     330
%    8.1 Ga     230
% 3)We multiply the matrix components(the first 9 components) of the compass
%   calibration data with the compass vector.

return
end

%  reads the Micro Conductivity data
function FCTD = FastCTD_ASCII_getMcr(FCTD)

try
    m = reshape(FCTD.mcr_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);

try
    FCTD.uConductivity = reshape(mm,10,[])';
catch
    FCTD.uConductivity = ones(0,10);
end

end

%  reads and apply calibration to the temperature data
function FCTD = FastCTD_ASCII_getTemp(FCTD)

a0 = FCTD.header.ta0;
a1 = FCTD.header.ta1;
a2 = FCTD.header.ta2;
a3 = FCTD.header.ta3;

rawT = hex2dec(FCTD.ctd_ASCII(:,1:6));
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

f = hex2dec(FCTD.ctd_ASCII(:,(1:6)+6))/256/1000;

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

rawP = hex2dec(FCTD.ctd_ASCII(:,(1:6)+12));

y = hex2dec(FCTD.ctd_ASCII(:,(1:4)+18))/13107;

t = ptempa0+ptempa1*y+ptempa2*y.^2;
x = rawP-ptca0-ptca1*t-ptca2*t.^2;
n = x*ptcb0./(ptcb0+ptcb1*t+ptcb2*t.^2);

FCTD.pressure = (pa0+pa1*n+pa2*n.^2-14.7)*0.689476;

return;
end

%  parse all the lines in the header of the file
function FCTD = FastCTD_ASCII_parseheader(FID)
FCTD = [];
fgetl(FID);
s=fgetl(FID);
[v,val]=FastCTD_ASCII_parseheadline(s);
if ~isempty(v)
    eval(['FCTD.header.' lower(v) '=' val ';']);
end
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
                disp(['Error occured in string: ' s]);
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
try
FID = fopen(fname,'r');
s=fscanf(FID,'%c');
fclose(FID);
    s=reshape(s,74,[])';


winch.payoutvel = str2num(s(:,44:49));
winch.payout = str2num(s(:,32:37));
winch.payoutAtm = str2num(s(:,24:30));
winch.current = str2num(s(:,51:57));
winch.time = str2num(s(:,2:11))/100/24/3600+ FCTD.header.offset_time;
winch.status = str2num(s(:,end-7:end-3));
catch err
    disp('Error in reading winch');
    disp(err);
    winch.payoutvel = [];
    winch.payout = [];
    winch.payoutAtm = [];
    winch.current = [];
    winch.time = [];
    winch.status = [];
    return;
end
end

%  reading GPS data
function GPS = FastCTD_ASCII_readGPS(fname,FCTD)

try
    FID = fopen(fname,'r');
    %%%%%
    frewind(FID);
    str = fread(FID,'*char');
    fclose(FID);
    % divide into lines and look for lines with length around the size of 71
    % char
    ind = [0; find(str == 10); length(str)+2];
    line_length = diff(ind)-1;
    ind(1) = 1;
    ind(end) = ind(end) - 1;
    
    good_str = false(size(str));
    
    for i = 1:length(line_length)
        if (line_length(i) >= 79)&&(line_length(i) <= 90)
            good_str(ind(i):ind(i+1)-1) = true;
        end
    end
    
    
    
    str = str(good_str);
    if ~isempty(str)
        data = textscan(str,'%*c%f%*s%f%f%s%f%s%*f%*f%*f%*f%*s%*f%*s%*s%*s','Delimiter',{'\n',',','$'});
    else
        GPS.time = [];
        GPS.latitude = [];
        GPS.longitude = [];
        GPS.GPS_time = [];
        return;
    end
    
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
catch err
    disp('Error in reading GPS');
    disp(err);
    GPS.time = [];
    GPS.GPS_time = [];
    GPS.latitude = [];
    GPS.longitude = [];
end
end

% %  a secondary function to convert hex to dec but making sure the arguments
% %  are correctly formated as hex
% function d = hex2dec(h)
% h(~((h>='0' & h<='9')|(h>='A' & h<='F')))='0';
% d = hex2dec(h);
% return;
% end

function corrected_time = correctNegativeTime(time)
corrected_time = time;
neg_time = time(time<0);
corrected_time(time<=0) = 2^64 + neg_time;
end