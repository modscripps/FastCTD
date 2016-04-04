clear;
matDataDir = '/Volumes/RR1513_ASIRI_1/FCTD/MAT/';
rotDataDir = '/Volumes/RR1513_ASIRI_1/FCTD/ROT/';
matFiles = dir([matDataDir 'FCTD_*.mat']);

if exist([rotDataDir 'matDataFilesLoaded.mat'],'file')
    load([rotDataDir 'matDataFilesLoaded.mat']);
else
    matDataFilesLoaded = {};
end

% matDataFilesLoaded{end+1:numel(matFiles)} = cell(1,numel(matFiles)-numel(matDataFilesLoaded));
for i = 1:(numel(matFiles)-1)
    if sum(strcmpi(matFiles(i).name,matDataFilesLoaded))>0
        continue;
    end
    disp(matFiles(i).name);
    load([matDataDir '/' matFiles(i).name]);
    
    if isempty(matDataFilesLoaded)
        matDataFilesLoaded = {matFiles(i).name};
    else
        matDataFilesLoaded{end+1} = matFiles(i).name;
    end
    if exist('FCTD','var') && isstruct(FCTD) && ~isempty(FCTD.time)
        time = FCTD.time;
        pts = numel(FCTD.time);
        multiplier = -1;
        
        [Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis([0, 1,0]);
        Rot_Mat = @(p,t,s)[ cos(t)*cos(s), -cos(p)*sin(s) + sin(p)*sin(t)*cos(s),  sin(p)*sin(s) + cos(p)*sin(t)*cos(s);
            cos(t)*sin(s),  cos(p)*cos(s) + sin(p)*sin(t)*sin(s), -sin(p)*cos(s) + cos(p)*sin(t)*sin(s);
            -sin(t),         sin(p)*cos(t),                         cos(p)*cos(t)];
        acce = (Rot_Mat(0,0,pi*1/4)*(Rot_mat*(FCTD.acceleration')))';
        acce(:,3) = -multiplier*acce(:,3);
        
        acc_xy_length = sqrt(sum(acce(:,1:2).^2,2));
        acc_length = sqrt(sum(acce.^2,2));
        
        comp = FCTD.compass;
        gyro = FCTD.gyro;
        acce = FCTD.acceleration;
        
        comp(:,3) = multiplier*comp(:,3);
        gyro(:,3) = multiplier*gyro(:,3);
        acce(:,3) = multiplier*acce(:,3);
        comp = comp';
        gyro = gyro';
        acce = acce';
        
        new_comp = NaN(size(comp))';
        new_gyro = NaN(size(comp))';
        new_acce = NaN(size(comp))';
        tic
        for k = 1:pts
            [Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis(acce(:,k)');
            new_comp(k,:) = Rot_mat*(comp(:,k));
            new_gyro(k,:) = Rot_mat*(gyro(:,k));
            new_acce(k,:) = Rot_mat*(acce(:,k));
            
        end
        toc
        
        
        COMP = medfilt1(new_comp,5,[],1);
        COMP(end-3:end,:) = new_comp(end-3:end,:);
        COMP_mag = repmat(sqrt(sum(COMP(:,1:2).*COMP(:,1:2),2)),[1 3]);
        COMP = COMP./COMP_mag;
        COMP = COMP(:,1)+1i*COMP(:,2);
        
        
        tot_rot = phase(COMP);
        
        save([rotDataDir '/' matFiles(i).name],'COMP','tot_rot','time');
    end
    clear FCTD;
end
save([rotDataDir 'matDataFilesLoaded.mat'],'matDataFilesLoaded');
disp('Done');

%%
rotFiles = dir([rotDataDir 'FCTD_*.mat']);
COMP = [];
tot_rot = 0;
time = [];
tic
for i = 738:numel(rotFiles)
    disp(rotFiles(i).name);
    rot = load([rotDataDir '/' rotFiles(i).name]);
    COMP = [COMP; rot.COMP];
    tot_rot = [tot_rot; tot_rot(end)+rot.tot_rot];
    time = [time; rot.time];
    clear rot;
end
tot_rot = tot_rot(2:end);
toc
disp('Done');

%%
t_offset = datenum(2015,09,00);
SN_figure(2,'w',1500,'h',900);
clf; 
plot(time-datenum(2015,09,00), tot_rot/pi/2,'linewidth',2)
grid on;
xlabel(['Day in ' datestr(t_offset+1,'mmmm, yyyy')]);
ylabel('Number of rotations');
title('FCTD: Rotation count on current line');
SN_setTextInterpreter('latex');
SN_printfig([rotDataDir '/currentRotFig.pdf']);

