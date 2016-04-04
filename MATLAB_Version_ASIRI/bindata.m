function [meanX,VarX,nX]=bindata(binx,biny,x,y,X);
% BINDATA does 2-D data binning.
% [meanX,varX,nX]=bindata(binx,biny,x,y,X);
%
% Where X is the data to binned.  X is located at points (x,y).  binx and
% biny are the bins to put the data is.  

% $Id: bindata.m,v 1.2 2003/09/30 18:37:05 jklymak Exp $
% $Log: bindata.m,v $
% Revision 1.2  2003/09/30 18:37:05  jklymak
% Redid so it no longer calls Mex File.  This is pretty fast now that

% MatLab does faster for-loops.
%

% check that x,y, and X are the same size
if sum(size(x))~=sum(size(y))
  error('x and y muxt be the same size');
end;
if sum(size(x))~=sum(size(X))
  error('x and X muxt be the same size');
end;

meanX = zeros(length(biny)-1,length(binx)-1);
nX = zeros(length(biny)-1,length(binx)-1);
VarX=nX;
goodda = find(~isnan(x+y));
x=x(goodda);
y=y(goodda);
X = X(goodda);
% this allows us to have variable bins
indx = min(max(floor(interp1(binx,1:length(binx),x,'lin','extrap')),1),length(binx)-1);
indy = min(max(floor(interp1(biny,1:length(biny),y,'lin','extrap')),1), ...
           length(biny)-1);
for i=1:length(x)
  meanX(indy(i),indx(i))=meanX(indy(i),indx(i))+X(i);
  nX(indy(i),indx(i))=nX(indy(i),indx(i))+1;
end;
nX(find(nX==0))=NaN;
meanX = meanX./nX;

for i=1:length(x)
  VarX(indy(i),indx(i))=(meanX(indy(i),indx(i))-X(i)).^2./nX(indy(i),indx(i));
end;
