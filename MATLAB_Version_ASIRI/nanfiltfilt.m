function y = nanfiltfilt(b,a,x)

% filtfilt, but removes nans
y=NaN*x;
ig=find(~isnan(x));

x=interp1(ig,x(ig),1:length(x));
ig=~isnan(x);
if sum(ig) > 3*max(numel(b),numel(a))
    y(ig)=filtfilt(b,a,x(ig)')';
else % temporary fix to avoid error
    y(ig)=conv2(x(ig)',b,'same')';
end
