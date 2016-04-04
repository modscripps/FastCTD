function PlotYEIonFCTD2(FCTD)
% date: 2013 05 07
pts = 48;
fpts = 6;

if pts > numel(FCTD.time)
    pts = numel(FCTD.time);
end
applyFiltering = false;
if applyFiltering
    comp = FCTD.compass(end-fpts-1:end,:);
    gyro = FCTD.gyro(end-fpts-1:end,:);
    acceleration = FCTD.acceleration(end-fpts-1:end,:);
    
    FCTD.compass = medfilt1(FCTD.compass,fpts/2,[],1);
    FCTD.gyro = medfilt1(FCTD.gyro,fpts/2,[],1);
    FCTD.acceleration = medfilt1(FCTD.acceleration,fpts/2,[],1);
    
    mygausswin = gausswin(fpts);
    mygausswin = mygausswin/sum(mygausswin);
    
    FCTD.compass = conv2(FCTD.compass,mygausswin,'same');
    FCTD.gyro = conv2(FCTD.gyro,mygausswin,'same');
    FCTD.acceleration = conv2(FCTD.acceleration,mygausswin,'same');
    
    FCTD.compass(end-fpts-1:end,:) = comp;
    FCTD.gyro(end-fpts-1:end,:) = gyro;
    FCTD.acceleration(end-fpts-1:end,:) = acceleration;
    
end

figure(1000);
set(gcf,'renderer','painters');
% clf;
% % subplot(2,3,5:6);
% % plot(FCTD.time(i+(0:(pts-1))),FCTD.pressure(i+(0:(pts-1))),'r-*','markersize',2);
% % ylim([0 2000]);
% axis ij;
% % hold on;
% ylabel('Pressure [dbar]','interpreter','latex');
% xlabel('Time (MM:SS) [UTC]','interpreter','latex');
% grid on;
% box on;
% datetick('x','MM:SS','keeplimits')
LHS = true;
if LHS
    multiplier = -1;
else
    multiplier = 1;
end

[Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis([0, 1,0]);
Rot_Mat = @(p,t,s)[ cos(t)*cos(s), -cos(p)*sin(s) + sin(p)*sin(t)*cos(s),  sin(p)*sin(s) + cos(p)*sin(t)*cos(s);
    cos(t)*sin(s),  cos(p)*cos(s) + sin(p)*sin(t)*sin(s), -sin(p)*cos(s) + cos(p)*sin(t)*sin(s);
    -sin(t),         sin(p)*cos(t),                         cos(p)*cos(t)];
acceleration = (Rot_Mat(0,0,pi*1/4)*(Rot_mat*(FCTD.acceleration(end-pts+1:end,:)')))';
acceleration(:,3) = -multiplier*acceleration(:,3);

acc_xy_length = sqrt(sum(acceleration(:,1:2).^2,2));
acc_length = sqrt(sum(acceleration.^2,2));

subplot(2,3,1);
plot([0, 0],[-1, 1],'color','k','linewidth',1,'linestyle','--');
hold on;
plot([-1, 1],[0, 0],'color','k','linewidth',1,'linestyle','--');
plot([-1, 1],[1, -1],'color','k','linewidth',1,'linestyle','--');
plot([1, -1],[1, -1],'color','k','linewidth',1,'linestyle','--');

text(0,0,'\qquad {\bf horizontal} \qquad',...
    'backgroundcolor','none','color','k','interpreter','latex','fontweight','bold',...
    'horizontalalignment','center','verticalalignment','middle','rotation',0,...
    'fontsize',15);

plot(acc_xy_length./acc_length,acceleration(:,3)./acc_length,'color','b','linewidth',0.5);

quiver(0,0,acc_xy_length(end)./acc_length(end),acceleration(end,3)./acc_length(end),0,'color','b','linewidth',5);
hold on;
text(0,-1.45,sprintf('\\quad%0.0f$^\\circ$ with respect to horizontal\\qquad',...
    asin(acceleration(end,3)/sqrt(sum(acceleration(end,:).*acceleration(end,:))))*180/pi),...
    'backgroundcolor','k','color','w','interpreter','latex','fontweight','bold',...
    'horizontalalignment','center','verticalalignment','middle');

xlim([-1.2 1.2]);
ylim([-1.2 1.2]);
xlabel('$r$','interpreter','latex');
ylabel('$z$','interpreter','latex');
set(gca,'dataaspectratio',[1 1 1],'xtick',[],'ytick',[]);
grid on;
box on;
hold off;
title('Pitch of FCTD Fish [$r$-$z$ plane]','interpreter','latex');

subplot(2,3,2);
plot([0, 0],[-1, 1],'color','k','linewidth',1,'linestyle','--');
hold on;
plot([-1, 1],[0, 0],'color','k','linewidth',1,'linestyle','--');
plot([-1, 1],[1, -1],'color','k','linewidth',1,'linestyle','--');
plot([1, -1],[1, -1],'color','k','linewidth',1,'linestyle','--');

text(0,0,'\qquad {\bf vertical} \qquad',...
    'backgroundcolor','none','color','k','interpreter','latex','fontweight','bold',...
    'horizontalalignment','center','verticalalignment','middle','rotation',90,...
    'fontsize',15);

plot(acceleration(:,1)./acc_xy_length,acceleration(:,2)./acc_xy_length,'color','b','linewidth',0.5);
quiver(0,0,acceleration(end,1)/acc_xy_length(end),acceleration(end,2)/acc_xy_length(end),'color','b','linewidth',5);

text(0,-1.45,sprintf('\\quad%0.0f$^\\circ$ with respect to vertical\\qquad',...
    asin(acceleration(end,1)/acceleration(end,2))*180/pi),...
    'backgroundcolor','k','color','w','interpreter','latex','fontweight','bold',...
    'horizontalalignment','center','verticalalignment','middle');

xlim([-1.2 1.2]);
ylim([-1.2 1.2]);
xlabel('$x$','interpreter','latex');
ylabel('$y$','interpreter','latex');
set(gca,'dataaspectratio',[1 1 1],'xtick',[],'ytick',[]);
grid on;
box on;
hold off;
% set(findall(gca,'type','text'),'interpreter','latex');
title('Roll of FCTD Fish [$x$-$y$ plane]','interpreter','latex');


comp = FCTD.compass(end-pts+1:end,:);
gyro = FCTD.gyro(end-pts+1:end,:);
acceleration = FCTD.acceleration(end-pts+1:end,:);

comp(:,3) = multiplier*comp(:,3);
gyro(:,3) = multiplier*gyro(:,3);
acceleration(:,3) = multiplier*acceleration(:,3);


for k = 1:pts
    [Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis(acceleration(k,:));
    comp(k,:) = Rot_mat*(comp(k,:)');
    gyro(k,:) = Rot_mat*(gyro(k,:)');
    acceleration(k,:) = Rot_mat*(acceleration(k,:)');
end

subplot(2,3,4);
plot3(comp(:,1)/0.4,comp(:,2)/0.4,comp(:,3)/0.4,'b*','markersize',2);
hold on;
plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r*','markersize',2);
plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g*','markersize',2);

quiver3(0,0,0,comp(end,1)/0.4,comp(end,2)/0.4,comp(end,3)/0.4,0,'color','b','linewidth',5);
quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,0,'color','r','linewidth',10);
quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,0,'color','g','linewidth',10);

xlim([-1 1]);
ylim([-1 1]);
zlim([-1 1]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
zlabel('z','interpreter','latex');
set(gca,'dataaspectratio',[1 1 1]);
grid on;
box on;
hold off;
title('top view [$x$-$y$ plane]','interpreter','latex');
view(0,90);

subplot(2,3,5);
plot3(comp(:,1)/0.4,comp(:,2)/0.4,comp(:,3)/0.4,'b-*','markersize',1);
hold on;
plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);

quiver3(0,0,0,comp(end,1)/0.4,comp(end,2)/0.4,comp(end,3)/0.4,0,'color','b','linewidth',5);
quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,0,'color','r','linewidth',10);
quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,0,'color','g','linewidth',10);

xlim([-1 1]);
ylim([-1 1]);
zlim([-1 1]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
zlabel('z','interpreter','latex');
set(gca,'dataaspectratio',[1 1 1]);
grid on;
box on;
hold off;
title('side view 1 [$x$-$z$ plane]','interpreter','latex');
%     view(60,30);
view(0,0);

subplot(2,3,6);
plot3(comp(:,1)/0.4,comp(:,2)/0.4,comp(:,3)/0.4,'b-*','markersize',1);
hold on;
plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);

quiver3(0,0,0,comp(end,1)/0.4,comp(end,2)/0.4,comp(end,3)/0.4,0,'color','b','linewidth',5);
quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,0,'color','r','linewidth',10);
quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,0,'color','g','linewidth',10);

xlim([-1 1]);
ylim([-1 1]);
zlim([-1 1]);
xlabel('x','interpreter','latex');
ylabel('y','interpreter','latex');
zlabel('z','interpreter','latex');
set(gca,'dataaspectratio',[1 1 1]);
grid on;
box on;
hold off;
title('side view 2 [$y$-$z$ plane]','interpreter','latex');
view(90,0);

subplot(2,3,3);
cla;
grid off;
box off;
set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w');
ylim([0 1]);
xlim([0,1]);
axis ij;
text(0,0,'Top panels: pitch and roll of FCTD Fish','interpreter','latex');
hold on;
text(0,0.075,'Bottom panels: acc. is projected to $z$-axis','interpreter','latex');
text(0,0.15,'[blue - COMPASS, red - GYRO, green - ACC]','interpreter','latex');
text(0,0.255,'Use roll of fish to figure out twists on cable','interpreter','latex');
text(0,0.33,'when pitch is less than 75$^\circ$ from vertical,','interpreter','latex');
text(0,0.405,'otherwise, use bottom-left panel.','interpreter','latex');
text(0,0.90,['Oldest record: ' datestr(FCTD.time(1),'yyyy-mm-dd HH:MM:SS.FFF')],'interpreter','latex','fontsize',12);
text(0,0.95,['Newest record: ' datestr(FCTD.time(end),'yyyy-mm-dd HH:MM:SS.FFF')],'interpreter','latex','fontsize',12);
text(0,1,['Last update: ' datestr(now,'yyyy-mm-dd HH:MM:SS.FFF')],'interpreter','latex','fontsize',12);
hold off;
end