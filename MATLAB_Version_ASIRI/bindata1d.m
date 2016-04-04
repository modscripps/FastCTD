function [meanX,VarX,nX,midbins]=bindata1d(binx,x,X,edgebins);
%
% BINDATA1D does 1-D data binning.
%
% Drives bindrv.  [meanX,varX,nX,midx]=bindata1d(binx,x,X); Where X is the
% data to binned.  X is located at points (x).  binx is the bins to
% put the data is.  Caution: binx and biny are not implemented to
% accept uneven bins.  If there is a need I can do this with some more
% work.
%
% [meanX,varX,nX,midx]=bindata1d(binx,x,X,1); 
% will put all data beyond the first and last bins into the first and last
% bins- makes it behave more like hist.m that way.

biny = [0 1e6];
y = 100+0*x;

if nargin<4
  edgebins=0;
end;
if edgebins
  in = find(x<=binx(1));
  x(in) = binx(1)+1e-16;
  in = find(x>=binx(end));
  x(in) = binx(end)+1e-16;
end;


if size(x,1)~=size(X,1);
  x=x';
end;
if size(x,1)~=size(X,1);
  error('x and X must be the same size');
end;

% check the dimensions
if size(binx,1)>1
  binx=binx';
  flip=1;
else
  flip=0;
end;
if size(binx,1)>1
  error('Can only accept a column vector for binx');
end;

good = find(~isnan(x) & ~isnan(X));
x=x(good)';
y=y(good)';
X=X(good)';
if (length(binx) > 1) && length(biny)>1
    [meanX,VarX,nX]=bindata(binx,biny,x,y,X);
else
    meanX = NaN;
    VarX = NaN;
    nX = 0;
end
bad = find(nX==0);
if ~isreal(X)
  meanX(bad) = NaN+sqrt(-1)*NaN;
else
  meanX(bad) = NaN;
end;
varX(bad)=NaN;

midbins = binx(1:end-1)+diff(binx)/2;
if flip
  meanX=meanX';
  VarX=VarX';
  nX=nX';
end;

%keyboard;



