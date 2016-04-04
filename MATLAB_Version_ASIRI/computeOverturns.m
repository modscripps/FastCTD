function [Eps,L_T,L,L_min,runMax] = computeOverturns(SA,t,p,varargin)
% computeOverturns detects overturns in a density profile and computes the
%   rate of dissipation (epsilon) due to such process. This function is
%   rewritten from Dr. Jennifer MacKinnon's compute_overturns2. There are
%   modifications to utilize the modern Gibbs SeaWater package and to
%   integrate a combination of both methods of detections using temperature
%   and/or density.
%
%   Epsilon = computeOverturns(SA,T,P) calculates the rate of dissipation
%   where there are overturns (using density inversion criteria). SA is
%   absolute salinity, T is in-situ temperature, P is pressure in dbars.
%
%   Such criteria are described in Galbraith & Kelley 1996 JAO Tech and
%   Gargett & Garner 2008 JAO Tech.
%   Criteria such as:
%   + Minimum overturn length (2 m as default value) [minOTsize]
%   + Minimum number of consecutive depth bins for each overturn (0 as
%       defalt value) [runMin]
%   + Noise level of measurements (5e-4 as default when relying on density,
%       1e-4 as default when relying on temperature) [noiseLevel]
%   + Overturn ratio, R0, (greater than 0.2 as default when relying on
%       density or 0.15 when relying on temperature) [R0Threshold] 
%       (Source: Gargett & Garner 2008 JAO Tech)
%
%   [Ep, L_T, L] = computeOverturns(SA,T,P) also returns Thorpe length
%   (L_T) and the overturn lenght (L)
%
%   When using computeOverturns(SA,T,P,OPTIONS), where OPTIONS are extra
%   options that can constrain how overturns are calculated. Such OPTIONS
%   are:
%       UseTemp - uses temperature instead of density for detecting
%           overturns
%       UseBoth - uses both temperature and density for dectecting
%           overturns and take the minimum of the two results
%       Latitude - integrates latitude in calculations of density,
%           potential temperature, and gravity. If not defined, default
%           value is 0.
%       MinOTsize - minimum length of overturns (2 m by default)
%       NoiseLevel - noise level of measurements (5e-4 as default when 
%           relying on density, 1e-4 as default when relying on
%           temperature)
%       R0Threshold - overturn ratio, R0, (greater than 0.2 as default
%           when relying on density or 0.15 when relying on temperature)
%       RunMin - minimum number of consecutive depth bins for each
%           overturn (0 as defalt value)
%
%   When using option UseBoth, user can set the R0Threshold and NoiseLevel
%   separately for temperature and density by using the options
%   tempR0Threshold, densR0Threshold, tempNoiseLevel, densNoiseLevel.
%
%   Example:
%       [Eps,L_T,L,L_min,runMax] = ...
%           computeOverturns(SA,T,P,...
%               'UseBoth','tempNoiseLevel',1e-4,'densNoiseLevel',5e-4,...
%               'tempR0Threshold',0.1,'densR0Threshold',0.2);
%
%   Update: 2013 03 20

if isempty(p) || isempty(t) || isempty(SA)
    error('MATLAB:computeOverturns:NotEnoughArgs','Not enough arguments.');
end

persistent argsNameToCheck;
if isempty(argsNameToCheck);
    argsNameToCheck = {'UseTemp','UseBoth','minOTsize','noiseLevel','runMin','R0Threshold',...
        'tempNoiseLevel','densNoiseLevel','tempR0Threshold','densR0Threshold','Latitude','Lat'};
end

useTemp = false;
minOTsize = 2;
noiseLevel = [];
runMin = 0;
R0Threshold = [];
useBoth = false;
tempNoiseLevel = [];
densNoiseLevel = [];
tempR0Threshold = [];
densR0Threshold = [];
lat = 0;

index = 1;
n_items = nargin-3;
while (n_items > 0)
    argsMatch = strcmpi(varargin{index},argsNameToCheck);
    i = find(argsMatch,1);
    if isempty(i)
        error('MATLAB:computeOverturns:wrongOption','Incorrect option specified: %s', varargin{index});
    end
    
    switch i
        case 1 % useTemp
            useTemp = true;
            index = index + 1;
            n_items = n_items-1;
        case 2 % useBoth
            useBoth = true;
            index = index + 1;
            n_items = n_items-1;
        case 3 % minOTsize
            minOTsize = varargin{index+1};
            if ~(isnumeric(minOTsize) && isscalar(minOTsize) && minOTsize >= 0)
                error('MATLAB:computeOverturns:minOTsize0Numeric','Minimum overturn scales must be a numeric scalar  >= 0.');
            end
            index = index +2;
            n_items = n_items-2;
        case 4 % noiseLevel
            noiseLevel = varargin{index+1};
            if ~(isnumeric(noiseLevel) && isscalar(noiseLevel) && noiseLevel >= 0)
                error('MATLAB:computeOverturns:noise0Numeric','Noise must be a numeric scalar >= 0.');
            end
            tempNoiseLevel = noiseLevel;
            densNoiseLevel = noiseLevel;
            index = index +2;
            n_items = n_items-2;
        case 5 % runMin
            runMin = varargin{index+1};
            if ~(isnumeric(runMin) && isscalar(runMin) && runMin >= 0)
                error('MATLAB:computeOverturns:runMin0Numeric','Minimum running length must be a numeric scalar>= 0.');
            end
            index = index +2;
            n_items = n_items-2;
        case 6 % R0Threshold
            R0Threshold = varargin{index+1};
            if ~(isnumeric(R0Threshold) && isscalar(R0Threshold) && R0Threshold >= 0 && R0Threshold <= 1)
                error('MATLAB:computeOverturns:R0Threshold0Numeric','R0Threshold must be a numeric scalar between 0 and 1.');
            end
            tempR0Threshold = R0Threshold;
            densR0Threshold = R0Threshold;
            index = index +2;
            n_items = n_items-2;
        case 7 % tempNoiseLevel
            tempNoiseLevel = varargin{index+1};
            if ~(isnumeric(tempNoiseLevel) && isscalar(tempNoiseLevel) && tempNoiseLevel >= 0)
                error('MATLAB:computeOverturns:noise0Numeric','Noise must be a numeric scalar >= 0.');
            end
            index = index +2;
            n_items = n_items-2;
        case 8 % densNoiseLevel
            densNoiseLevel = varargin{index+1};
            if ~(isnumeric(densNoiseLevel) && isscalar(densNoiseLevel) && densNoiseLevel >= 0)
                error('MATLAB:computeOverturns:noise0Numeric','Noise must be a numeric scalar >= 0.');
            end
            index = index +2;
            n_items = n_items-2;
        case 9 % tempR0Threshold
            tempR0Threshold = varargin{index+1};
            if ~(isnumeric(tempR0Threshold) && isscalar(tempR0Threshold) && tempR0Threshold >= 0 && tempR0Threshold <= 1)
                error('MATLAB:computeOverturns:R0Threshold0Numeric','R0Threshold must be a numeric scalar between 0 and 1.');
            end
            index = index +2;
            n_items = n_items-2;
        case 10 % densR0Threshold
            densR0Threshold = varargin{index+1};
            if ~(isnumeric(densR0Threshold) && isscalar(densR0Threshold) && densR0Threshold >= 0 && densR0Threshold <= 1)
                error('MATLAB:computeOverturns:R0Threshold0Numeric','R0Threshold must be a numeric scalar between 0 and 1.');
            end
            index = index +2;
            n_items = n_items-2;
        case {11,12} % lat
            lat = varargin{index+1};
            if ~(isnumeric(lat) && isscalar(lat) && lat >= -90 && lat <= 90)
                error('MATLAB:computeOverturns:R0Threshold0Numeric','Latitude must be a numeric scalar between -/+ 90.');
            end
            index = index +2;
            n_items = n_items-2;
    end
end

p = p(:);
t = t(:);
SA = SA(:);

if (sum(~isnan(p)) < 4) || (sum(~isnan(t)) < 4) || (sum(~isnan(SA)) < 4)
    error('MATLAB:computeOverturns:notEnoughPts','Not enough points to do calculation.');
end

if isempty(noiseLevel)
    if useTemp && isempty(tempNoiseLevel)
        tempNoiseLevel = 1e-4;
        noiseLevel = 1e-4;
    elseif useTemp || isempty(densNoiseLevel)
        noiseLevel = 5e-4;
        densNoiseLevel = noiseLevel;
    else
        noiseLevel = densNoiseLevel;
    end
end

if isempty(tempNoiseLevel)
    tempNoiseLevel = noiseLevel;
end

if isempty(densNoiseLevel)
    densNoiseLevel = noiseLevel;
end

if isempty(R0Threshold)
    if useTemp && isempty(tempR0Threshold)
        R0Threshold = 0.15;
        tempR0Threshold = 0.15;
    elseif useTemp || isempty(densR0Threshold)
        R0Threshold = 0.2;
        densR0Threshold = R0Threshold;
    else
        R0Threshold = densR0Threshold;
    end
end

if isempty(tempR0Threshold)
    tempR0Threshold = R0Threshold; % this is not used unless in the case of useBoth option
elseif useTemp
    R0Threshold = tempR0Threshold;
end

if isempty(densR0Threshold)
    densR0Threshold = R0Threshold; % this is not used unless in the case of useBoth option
elseif ~useTemp
    R0Threshold = densR0Threshold;
end

if useBoth
    [Eps1,L_T1,L1,L_min1,runMax1] = computeOverturns(SA,t,p,...
        'UseTemp','minOTsize', minOTsize, 'noiseLevel', noiseLevel,'tempNoiseLevel',tempNoiseLevel,...
        'runMin',runMin,'tempR0Threshold',tempR0Threshold,'Latitude',lat);
    [Eps2,L_T2,L2,L_min2,runMax2] = computeOverturns(SA,t,p,...
        'minOTsize', minOTsize, 'noiseLevel', noiseLevel,'densNoiseLevel',densNoiseLevel,...
        'runMin',runMin,'densR0Threshold',densR0Threshold,'Latitude',lat);
    Eps = min(Eps1,Eps2);
    L_T = min(L_T1,L_T2);
    L = min(L1,L2);
    L_min = min(L_min1,L_min2);
    runMax = min(runMax1,runMax2);
    
    Eps(isnan(Eps1)|isnan(Eps2)) = NaN;
    L_T(isnan(L_T1)|isnan(L_T2)) = NaN;
    L(isnan(L1)|isnan(L2)) = NaN;
    L_min(isnan(L_min1)|isnan(L_min2)) = NaN;
    runMax(isnan(runMax1)|isnan(runMax2)) = NaN;
    return;
end

if range(p) > 1500
    p_ref_bin = 1000;
    p_ref = (nanmin(p)+p_ref_bin/2):dref:nanmax(p);
else
    p_ref_bin = range(p);
    p_ref = (nanmin(p)+nanmax(p))/2;
end

Eps = NaN(size(p)); % epsilon (rate of dissipation)
L_T = zeros(size(p)); % thorpe scale (rms of all overturn lengths in the same region) (meters)
L = NaN(size(p));   % overturn length (meters)
L_min = NaN(size(p)); % minimum overturn length that is above the noise level (meters)
runMax = NaN(size(p)); % maximum number of consecutive overtuning cells

for p_ref_i = p_ref
    pDens = gsw_pot_rho_t_exact(SA,t,p,p_ref_i);
    pTemp = gsw_pt_from_t(SA,t,p,p_ref_i);
    cTemp = gsw_CT_from_t(SA,t,p); % conservative temperature;
    depth = gsw_depth_from_z(gsw_z_from_p(p,lat));
    
    % set up filtering window over 10 dbars
    dz = abs(nanmedian(diff(depth)));
    winsize = ceil(10/dz);
    mygausswin = gausswin(winsize)*gausswin(1)';
    mygausswin = mygausswin/(sum(mygausswin(:)));
    
    % sort density profiles before calculating buoyancy frequency
    [~,srt_ind] = sort(pDens(:));
    [N2_smooth,p_N2] = gsw_Nsquared(nanfiltfilt(mygausswin,1,SA(srt_ind)),nanfiltfilt(mygausswin,1,cTemp(srt_ind)),p(srt_ind),lat);
%     depth_N2 = gsw_depth_from_z(gsw_z_from_p(p_N2,lat));
    
    % filter out NaNs in profiles
    ind = ~isnan(pDens);
    
    p_good = p(ind);
    pTemp = pTemp(ind);
    pDens = pDens(ind);
%     cTemp = cTemp(ind);
    depth = depth(ind);
    
    clear good_ind;
    
    % set quantity to use for detecting overturn
    if useTemp
        V = pTemp;
    else
        V = pDens;
    end
    
    % sort density or temperature profile to determine overturn
    sig = sign(nanmedian(diff(V)));
    [~, ind] = sort(sig*V);
%     [V_srt, ind] = sort(sig*V);
%     V_srt = sig*V_srt;
    
    % determine how much shift after sorting
%     p_srt = p_good(ind);

    z_srt = depth(ind);
    dz = depth - z_srt; % [meter]
    csdz = -cumsum(dz); % [meter]
    threshold = 1e-8; % [meter]
    
    start = find(csdz(1:end-1)<threshold & csdz(2:end)>=threshold)+1;
    if dz(1)<0
        start = [1; start];
    end;
    stops = find(csdz(1:end-1)>=threshold & csdz(2:end)<threshold)+1;
    
    N2_OT = NaN(size(dz)); 
    L_T0 = zeros(size(dz));
    L_min0 = NaN(size(dz)); 
    L0 = NaN(size(dz)); 
    runMax0 = NaN(size(dz));
%     R0tot=NaN(size(dz));
    for i = 1:numel(start)
%         ind = clip((start(i)-1):(stops(i)+1),1,numel(dz)); % this method
%         seems to add one extra cell
        ind = clip((start(i)):(stops(i)+1),1,numel(dz));
        
        indp = p_N2 > min(p_good(ind)) & p_N2<max(p_good(ind));
        noiseTH = 2*9.8/nanmean(N2_smooth(indp))*(useTemp*tempNoiseLevel + (~useTemp)*densNoiseLevel)/1027; % this is the noisy overturn length [meters]
        L_min0(ind) = noiseTH;
        
        Dz=max(depth(ind))-min(depth(ind)); % find the size of the overturning cell [meters]
        L0(ind) = Dz;
        
        Drho=(max(pDens(ind))-min(pDens(ind))); % density change acroos the overturn [kg m^-3]
        
        ind2=find(diff(sign(dz(ind)))==0); % find consecutive cells that are overturning
        run1 = 1;
        if numel(ind2)>1            
            % this method is to find the actual number of cells of the
            % overturns; this method is different from Jen's method to cut
            % out the while loop
            ind3=find(diff(ind2)>1);
            consec_ot_beg = ind2([1; ind3+1]);
            consec_ot_end = ind2([ind3; numel(ind2) - 1])+1;
            run1 = run1 + max(consec_ot_end-consec_ot_beg);
        end
        runMax0(ind) = run1;
        
        % apply Gargett and Garner 2008 JTech criterion
        Lp = sum((V(ind)-sort(V(ind)))>0);
        Lm = sum((V(ind)-sort(V(ind)))<0);
        R0 = min(Lp/numel(ind),Lm/numel(ind));
        
        % if the overturn meets all the criteria below then calculate some
        % quantities
        if ...
                (Dz > minOTsize) &&...
                (Dz > noiseTH )&&...
                (Drho > 2*noiseLevel) &&...
                (run1 > runMin) &&...
                (max(abs(V(ind)-sort(V(ind))))> 2*(useTemp*tempNoiseLevel + (~useTemp)*densNoiseLevel)) &&...
                (R0>R0Threshold)
            N2_OT(ind) = gsw_grav(lat,mean(p_good(ind)))/mean(pDens(ind)).*Drho/Dz;
            L_T0(ind) = sqrt(mean(dz(ind).^2));
%             R0tot(ind)=R0;
        else
            N2_OT(ind)=NaN;
            L_min0(ind)=NaN; 
            L0(ind)=NaN; 
            L_T0(ind)=NaN; 
%             R0tot(ind)=NaN;
        end
    end
    ind = p> (p_ref_i - p_ref_bin/2) & p<=(p_ref_i + p_ref_bin/2);
    
    [~,ind2] = unique(p_good);
    L_T(ind) = interp1(p_good(ind2),L_T0(ind2),p(ind));
    Eps(ind) = interp1(p_good(ind2),0.64*L_T0(ind2).^2.*sqrt(N2_OT(ind2)).^3,p(ind));
    L_min(ind) = interp1(p_good(ind2),L_min0(ind2),p(ind));
    L(ind) = interp1(p_good(ind2),L0(ind2),p(ind));
    runMax(ind) = interp1(p_good(ind2),runMax0(ind2),p(ind));
    
    L_T(isnan(p)) = NaN;
    Eps(isnan(Eps)&~isnan(p))=1e-11;
    L_T(isnan(L_T)&~isnan(p))=0;
    L_min(isnan(L_min)&~isnan(p))=0;
    L(isnan(L)&~isnan(p))=0;
    runMax(isnan(runMax)&~isnan(p))=0;
end
    
    