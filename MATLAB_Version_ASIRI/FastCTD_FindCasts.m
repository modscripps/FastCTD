function FCTD = FastCTD_FindCasts(FCTD,varargin)
% FCTD = FastCTD_FindCasts(FCTD);
%   finds when the FastCTD is going up and when it is going down
%   if 'UPCAST' is specified then the profile will search for upcast but by
%   defalt it would search for downcasts
%
%   In this data set we assume the data is in descending order of time
%
% Written by Jody Klymak
% Updated 2011 07 14 by San Nguyen
% Updated 2012 09 29 by San Nguyen



if ~isfield(FCTD,'pressure')
    return;
end;
% use 20 point median filter to smooth out the pressure field
p = medfilt1(FCTD.pressure,256);
% try to smooth out the data a bit
dp = conv2(diff(conv2(p,ones(256,1)/256,'same'),1,1)',ones(1,256)/256,'same');
% keyboard;
%downLim = 0.1;
downLim = 0.025;
downCast = true;

persistent argsNameToCheck;
if isempty(argsNameToCheck);
    argsNameToCheck = {'downLim','threshold','upcast','downcast'};
end

index = 1;
n_items = nargin-1;
while (n_items > 0)
    argsMatch = strcmpi(varargin{index},argsNameToCheck);
    i = find(argsMatch,1);
    if isempty(i)
        error('MATLAB:FastCTD_FindCasts:wrongOption','Incorrect option specified: %s',varargin{index});
    end
    
    switch i
        case 1 % downLim
            if n_items == 1
                error('MATLAB:FastCTD_FindCasts:missingArgs','Missing input arguments');
            end
            downLim = varargin{index+1};
            if downLim == 0 
                error('MATLAB:FastCTD_FindCasts:downLim0Err','The threshold cannot be zero!');
            end
            index = index +2;
            n_items = n_items-2;
        case 2 % downLim
            if n_items == 1
                error('MATLAB:FastCTD_FindCasts:missingArgs','Missing input arguments');
            end
            downLim = varargin{index+1};
            if downLim == 0 
                error('MATLAB:FastCTD_FindCasts:downLim0Err','The threshold cannot be zero!');
            end
            index = index +2;
            n_items = n_items-2;
        case 3 % upcast
            downCast = false;
            
            index = index + 1;
            n_items = n_items - 1;
        case 4 % downcast
            downCast = true;
            
            index = index + 1;
            n_items = n_items - 1;
    end
end

%defining the threshold for going up and down
if downCast && downLim < 0
    downLim = -downLim;
elseif (~downCast) && downLim > 0% going up
    downLim = -downLim;
end

if downCast
    dn = find(dp>downLim);
else
    dn = find(dp<downLim);
end

% find all indices of going down

if isempty(dn)
    return;
end;

dn = [0, dn];


% find jumps in indices to indicate a start of a profile
startdown = dn(find(diff(dn)>1)+1);

if isempty(startdown);
    return;
end;

dn = dn(2:end);
FCTD.drop = 0*FCTD.time;

if dn(1)<startdown(1)
    startdown=[dn(1) startdown];
end;

if startdown(end)<dn(end);
    startdown = [startdown dn(end)];
end;

for i=1:(length(startdown)-1);
    in = intersect(startdown(i):startdown(i+1)-1,dn);
    FCTD.drop(in) = i;
end;

end
